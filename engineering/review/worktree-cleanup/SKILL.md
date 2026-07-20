---
name: worktree-cleanup
description: Post-merge teardown for a git worktree - confirm the PR merged, remove the worktree, delete the local + remote branch, prune stale metadata, and refresh the primary checkout's main. Triggers on "clean up worktree", "teardown worktree", "post-merge cleanup", "remove this worktree and branch", "reclaim the worktree".
argument-hint: [worktree-path | branch | ticket]
---

# worktree-cleanup — post-merge worktree teardown

Run this **after a branch's PR is merged** to reclaim the worktree it lived in and the branch it carried. Destructive — it removes a worktree and deletes branches — so the merged-state gate below is mandatory, not optional. When the PR is still open, this skill stops; keep working in the worktree instead.

You cannot remove a worktree you are standing in. Run every git command with `-C <primary>` (the main checkout), or `cd` there first.

## Identify scope

- **Target** from `$ARGUMENTS` — a worktree path, a branch name, or a ticket that maps to one. Else infer from context (the worktree you were just working in, or the current branch).
- List worktrees and match: `git worktree list`. Record the **worktree path**, the **branch** it has checked out, and the **primary checkout** (the non-worktree entry, usually `main`).

Completion: you can name the exact worktree path, its branch, and the primary checkout before touching anything.

## Gate: confirm the PR is MERGED

Do **not** destroy anything until the branch's PR is merged:

```bash
gh pr list --head <branch> --state merged --json number,url,mergedAt
```

- A merged entry returns → proceed.
- The PR is still **open** (or no merged PR exists) → stop and report which. Only override on explicit user instruction (e.g. branch abandoned, intentionally never merged) — and say so in the report.

## Teardown

Order matters: a branch can't be deleted while a worktree has it checked out, so the worktree goes first.

**1. Remove the worktree.** Post-merge the working tree should be clean:
```bash
git -C <primary> worktree remove <worktree-path>
```
If git refuses (uncommitted changes or untracked files left behind), **stop and surface it** — don't reach for `--force`; the user may have unsaved work there.

**2. Delete the local branch.** Now free — no worktree holds it. Squash-merge rewrites history, so `git branch -d` reports "not fully merged" and refuses; the merged-state gate already confirmed the PR landed, so force-delete is the correct call here:
```bash
git -C <primary> branch -D <branch>
```

**3. Delete the remote branch** if it still exists (many repos auto-delete on merge):
```bash
git -C <primary> ls-remote --exit-code --heads origin <branch> >/dev/null 2>&1 \
  && git -C <primary> push origin --delete <branch> || echo "remote branch already gone"
```

**4. Prune stale worktree metadata:** `git -C <primary> worktree prune`.

## Refresh the primary checkout

Leave the primary sitting on the merged `main`, ready for the next branch:
```bash
git -C <primary> checkout main && git -C <primary> pull --ff-only
```
`--ff-only` keeps it honest — if the primary has local divergence it errors instead of forging a merge commit; surface that rather than papering over it.

## Optional: per-repo teardown hooks

Some repos provision more than a worktree per branch and need matching teardown. These are **not** part of the generic flow — run one only when the repo actually uses it, and mirror whatever the branch's setup created:

- **Scratch database** — a per-branch dev DB (`myapp_<suffix>`) cloned at setup. Drop it before removing the worktree, since its name usually lives in the worktree's `.env`: `psql -d postgres -c 'DROP DATABASE IF EXISTS <name> WITH (FORCE);'` (`FORCE` terminates lingering connections so the drop doesn't block).
- **Cleanup script** — if the repo ships one (`scripts/cleanup*.sh`, a `make teardown` target), prefer it over hand-rolled steps.
- **Post-merge migration on primary** — if the merged branch added a schema migration and the primary dev DB never applied it, apply it now so the next session doesn't break on a missing column. Report failures, don't force-fix.

If you find no such setup, say so — skipping a hook the repo doesn't use is the right outcome, not an omission.

## Report

Worktree removed (path) · PR merged-state · branches deleted (local / remote, or "remote already gone") · primary refreshed (new HEAD) · any per-repo hook run or skipped-why. Call out anything skipped — PR still open, dirty worktree, non-ff main — so nothing is silently left behind.
