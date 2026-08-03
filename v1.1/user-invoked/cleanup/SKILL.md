---
name: cleanup
description: "Post-merge teardown for finished work — confirm every PR merged, then reclaim what it left on your machine: the stack, the worktree, the local + remote branches, any per-branch scratch DB, Docker leftovers, stale metadata, and a refreshed main."
disable-model-invocation: true
argument-hint: [worktree-path | branch | ticket]
---

# cleanup — post-merge ticket teardown

Run this **after a ticket's PR is merged** to reclaim everything the work left behind: the worktree it lived in (if it used one), the branch it carried, any per-branch scratch DB, and a primary checkout left sitting on a fresh `main`. Destructive — it removes a worktree and deletes branches — so the merged-state gate below is mandatory, not optional. When the PR is still open, this skill stops; keep working instead.

The work may have lived in one of three shapes; detect which before touching anything:

- **Stack** — a chain of layer branches in one worktree, one per ticket, each with its own PR. Every PR must be merged before teardown; `gh stack` reclaims the branches, this skill reclaims everything else.
- **Worktree ticket** — a single branch checked out in a dedicated `git worktree`. Full teardown: remove the worktree, then the branch, DB, metadata.
- **Plain-branch ticket** — the branch was worked directly in the primary checkout (no worktree). No worktree to remove; still delete the local + remote branch and any per-branch DB.

You cannot remove a worktree you are standing in, and you cannot delete a branch that is currently checked out. Run every git command with `-C <primary>` (the main checkout), or `cd` there first. If you're inside the target worktree or on the target branch, move the primary to `main` (see [Refresh](#refresh-the-primary-checkout)) before deleting.

## Identify scope

- **Target** from `$ARGUMENTS` — a worktree path, a branch name, or a ticket that maps to one. Else infer from context (the worktree you were just working in, or the current branch).
- List worktrees: `git worktree list`. Record the **primary checkout** (the non-worktree entry, usually on `main`).
- **Decide the shape**, in order:
  - `gh stack view --json` succeeds → **stack**. Record every branch in it and the worktree holding them. (Exit **2** or **9** → not a stack; fall through.)
  - A worktree entry holds the target branch → **worktree ticket**. Record the worktree path and its branch.
  - Neither → **plain-branch ticket**. Record just the branch; there is no worktree to remove.

Completion: you can name the target branch (or every branch in the stack), whether a worktree holds it and its path, and the primary checkout — before touching anything.

## Gate: confirm the work is MERGED

Do **not** destroy anything until the work has landed:

```bash
gh pr list --head <branch> --state merged --json number,url,mergedAt
```

For a **stack**, run this for **every** branch in it — a stack is torn down all-or-nothing, so a single unmerged layer stops the whole teardown. `gh stack view --json` reports each layer's PR state in one call; use it, then confirm the merges.

- Every PR merged → proceed.
- Any PR still **open** (or no merged PR exists) → stop and report which. Only override on explicit user instruction (e.g. branch abandoned, intentionally never merged) — and say so in the report.

## Teardown

Order matters: a branch can't be deleted while a worktree has it checked out (or while it's the current branch), so free it first.

**0. Retire the stack** — *stack shape only.* Two commands reclaim every branch the stack held, so steps 2 and 3 below have nothing left to do:

```bash
gh stack sync --prune   # fast-forward trunk, delete local branches whose PRs merged
gh stack unstack        # drop local tracking and unstack on GitHub
```

Any branch `--prune` leaves behind (it skips branches with unmerged commits) is a signal that work never landed — surface it rather than force-deleting, then continue with the shared steps below.

**1. Remove the worktree** — *worktree tickets only; skip for plain-branch tickets.* Post-merge the working tree should be clean:
```bash
git -C <primary> worktree remove <worktree-path>
```
If git refuses (uncommitted changes or untracked files left behind), **stop and surface it** — don't reach for `--force`; the user may have unsaved work there.

**2. Delete the local branch** — *skip whatever step 0 already pruned.* For a plain-branch ticket, first make sure the primary isn't sitting on it — checkout `main` there (see [Refresh](#refresh-the-primary-checkout)) or the delete will refuse. Squash-merge rewrites history, so `git branch -d` reports "not fully merged" and refuses; the merged-state gate already confirmed the PR landed, so force-delete is the correct call here:
```bash
git -C <primary> branch -D <branch>
```

**3. Delete the remote branch** if it still exists (many repos auto-delete on merge):
```bash
git -C <primary> ls-remote --exit-code --heads origin <branch> >/dev/null 2>&1 \
  && git -C <primary> push origin --delete <branch> || echo "remote branch already gone"
```

**4. Prune stale worktree metadata:** `git -C <primary> worktree prune`. Harmless to run even for a plain-branch ticket.

## Refresh the primary checkout

Leave the primary sitting on the merged `main`, ready for the next branch:
```bash
git -C <primary> checkout main && git -C <primary> pull --ff-only
```
`--ff-only` keeps it honest — if the primary has local divergence it errors instead of forging a merge commit; surface that rather than papering over it.

## Per-ticket teardown hooks

The work may have provisioned more than a branch — a scratch DB, generated artifacts — that outlives the branch and needs matching teardown. This applies to **both** shapes: a plain-branch ticket can just as easily have created a per-branch DB. Run a hook only when the ticket actually used it, and mirror whatever the setup created:

- **Scratch database** — a per-branch dev DB (`myapp_<suffix>`) cloned at setup. Drop it, since its name usually lives in the branch's `.env`: `psql -d postgres -c 'DROP DATABASE IF EXISTS <name> WITH (FORCE);'` (`FORCE` terminates lingering connections so the drop doesn't block). For a worktree ticket the `.env` sits in the worktree — read the DB name *before* removing the worktree, or you'll lose the pointer.
- **Cleanup script** — if the repo ships one (`scripts/cleanup*.sh`, a `make teardown` target), prefer it over hand-rolled steps.
- **Docker stack** — if the repo ships a compose file, run the [Docker teardown](docker.md): sort artifacts into **keyed** (this ticket's, destroy) and **dangling** (untagged images, anonymous volumes — report, then reclaim on the user's go-ahead). Almost nothing is keyed by default, so this hook is mostly the dangling pass; a keyed stack must come down *before* the worktree is removed.
- **Other per-branch artifacts** — temp files and generated output keyed to the branch/ticket. Remove what the setup created; leave shared infrastructure alone.
- **Post-merge migration on primary** — if the merged branch added a schema migration and the primary dev DB never applied it, apply it now so the next session doesn't break on a missing column. Report failures, don't force-fix.

If you find no such setup, say so — skipping a hook the repo doesn't use is the right outcome, not an omission.

## Report

Shape (stack of N / worktree / plain branch) · stack unstacked and pruned or n/a · worktree removed (path) or n/a · PR merged-state (every layer, for a stack) · branches deleted (local / remote, or "remote already gone") · DB / hooks dropped or skipped-why · Docker: keyed stack torn down or n/a, dangling reclaimed (size) or awaiting go-ahead · primary refreshed (new HEAD). Call out anything skipped — PR still open, dirty worktree, non-ff main — so nothing is silently left behind.
