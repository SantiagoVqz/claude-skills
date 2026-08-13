---
name: cleanup
description: "Post-merge teardown for a landed ticket — confirm its PR merged, verify the ticket issue closed, then reclaim what the work left on your machine: the worktree, the branches, the per-worktree scratch DB, Docker leftovers, stale metadata, and a refreshed trunk."
disable-model-invocation: true
argument-hint: [worktree-path | ticket-branch | ticket]
---

# cleanup — post-merge ticket teardown

Run this **once per ticket**, after its PR is merged into the trunk, to reclaim everything the work left behind: the worktree it lived in, the ticket branch, the per-worktree scratch DB, and a primary checkout left sitting on a fresh trunk. It also verifies the ticket issue closed — the issue closes with the worktree.

**Ticket-scoped.** The unit of work is one ticket: one worktree, one branch off the trunk, one PR (opened by `/ship`), merged by the human. Everything provisioned for that worktree — env, ports, scratch DB — is reclaimed here.

Destructive — it removes a worktree and deletes branches — so the merged-state gate below is mandatory. When the PR is still open, this skill stops.

**Trunk** = the branch this repo merges into (`develop` on a git-flow repo, `main` otherwise). Default to the default branch (`git symbolic-ref refs/remotes/origin/HEAD`); a repo carrying both `main` and `develop` is running git-flow, so the trunk is `develop`. Teardown that hardcodes `main` on a `develop` repo leaves the primary stale and the next worktree branched off the wrong base.

You cannot remove a worktree you are standing in, and you cannot delete a branch that is currently checked out. Run every git command with `-C <primary>` (the primary checkout), or `cd` there first.

## Identify scope

- **Target** from `$ARGUMENTS` — a worktree path, a ticket branch, or a ticket that maps to one. Else infer from context (the worktree you were just working in, or the current branch).
- List worktrees: `git worktree list`. Record the **primary checkout** (the non-worktree entry, usually sitting on the trunk).
- **Trunk** — per the rule above; confirm with the user if ambiguous.
- **Ticket branch** — `<type>/<slug>`, the ticket's only branch, held by the target worktree.

Completion: you can name the ticket branch, the worktree holding it and its path, the primary checkout, and the trunk — before touching anything.

## Gate: confirm the work is MERGED

Do **not** destroy anything until the ticket branch has landed:

```bash
gh pr list --head <ticket-branch> --state merged --json number,url,mergedAt
```

(GitLab: `glab mr list` equivalents per the tracker doc, here and throughout. No remote → squash-merges defeat `git branch --merged`, so ask the user to confirm the branch landed on the trunk; their confirmation is the gate.)

- Merged → proceed.
- Still **open** (or no merged PR exists) → stop and say so. Only override on explicit user instruction (e.g. branch abandoned, intentionally never merged) — and say so in the report.

## Verify the ticket issue closed

`/ship` put `Closes #<ticket>` in the PR body, and the keyword fires when the PR merges into the repository's **default branch**:

```bash
gh pr view <n> --json body --jq '.body | scan("[Cc]loses #[0-9]+")'
gh issue view <n> --json number,state
```

- Trunk **is** the default branch (the normal case) → the issue should already be closed. Verify rather than assume — a body that lost the keyword leaves it open silently.
- Trunk is `develop` but the default branch is `main` → the keyword never fired; closing by hand here is the normal path, not an exception.

Close anything still open — `gh issue close <n> --reason completed` — and **name it in the report**.

**Spec issue.** If this ticket belongs to a spec, check its siblings: this ticket closing may have been the spec's last. All tickets closed → close the spec issue too, and say so. On a **local markdown** tracker: set the ticket file's Status to `done`; when every ticket file in the spec's folder is `done`, mark the spec file `done` as well.

Completion: the ticket issue is closed, and the spec issue's state (still open with N tickets remaining, or closed here) is named in the report.

## Teardown

Order matters: a branch can't be deleted while a worktree has it checked out, so free it first.

**1. Remove the worktree.** Post-merge the working tree should be clean:
```bash
git -C <primary> worktree remove <worktree-path>
```
If git refuses (uncommitted changes or untracked files left behind), **stop and surface it** — don't reach for `--force`; the user may have unsaved work there.

**2. Delete the local ticket branch.** Squash-merge rewrites history, so `git branch -d` reports "not fully merged" and refuses; the merged-state gate already confirmed the PR landed, so force-delete is the correct call:
```bash
git -C <primary> branch -D <ticket-branch>
```

**3. Delete the remote branch** if it still exists (many repos auto-delete on merge):
```bash
git -C <primary> ls-remote --exit-code --heads origin <ticket-branch> >/dev/null 2>&1 \
  && git -C <primary> push origin --delete <ticket-branch> || echo "remote branch already gone"
```

**4. Prune stale worktree metadata:** `git -C <primary> worktree prune`.

## Refresh the primary checkout

Leave the primary sitting on the merged trunk, ready for the next worktree to branch off it:
```bash
git -C <primary> checkout <trunk> && git -C <primary> pull --ff-only
```
`--ff-only` keeps it honest — if the primary has local divergence it errors instead of forging a merge commit; surface that rather than papering over it.

## Per-worktree teardown hooks

Provisioning may have created more than a branch — a scratch DB, generated artifacts — that outlives it. Everything here is **per worktree**, matching what setup created, and runs once:

- **Scratch database** — the per-worktree dev DB (`myapp_<suffix>`) cloned at provisioning. Drop it: `psql -d postgres -c 'DROP DATABASE IF EXISTS <name> WITH (FORCE);'` (`FORCE` terminates lingering connections so the drop doesn't block). Its name lives in the worktree's `.env` — read it *before* removing the worktree, or you'll lose the pointer. A worktree that shared the main dev DB (no `provision.sh db`) has nothing to drop.
- **Cleanup script** — if the repo ships one (`scripts/cleanup*.sh`, a `make teardown` target), prefer it over hand-rolled steps.
- **Docker stack** — if the repo ships a compose file, run the [Docker teardown](docker.md): sort artifacts into **keyed** (this worktree's, destroy) and **dangling** (untagged images, anonymous volumes — report, then reclaim on the user's go-ahead). Almost nothing is keyed by default, so this hook is mostly the dangling pass; a keyed stack must come down *before* the worktree is removed.
- **Other per-worktree artifacts** — temp files and generated output keyed to the ticket. Remove what the setup created; leave shared infrastructure alone.
- **Post-merge migration on primary** — if the merged branch added a schema migration and the primary dev DB never applied it, apply it now so the next session doesn't break on a missing column. Report failures, don't force-fix.

If you find no such setup, say so — skipping a hook the repo doesn't use is the right outcome, not an omission.

## Report

Trunk · PR merged-state · ticket issue closed (by keyword or by hand) · spec issue state (open, N tickets left / closed here / n-a) · worktree removed (path) · branches deleted (local / remote, or "remote already gone") · DB / hooks dropped or skipped-why · Docker: keyed stack torn down or n/a, dangling reclaimed (size) or awaiting go-ahead · primary refreshed to `<trunk>` (new HEAD). Call out anything skipped — PR still open, dirty worktree, non-ff trunk — so nothing is silently left behind.
