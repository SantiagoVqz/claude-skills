---
name: cleanup
description: "Post-merge teardown for a finished spec — confirm the feature branch merged, close the spec issue, then reclaim what the work left on your machine: the worktree, the branches, the per-worktree scratch DB, Docker leftovers, stale metadata, and a refreshed trunk."
disable-model-invocation: true
argument-hint: [worktree-path | feature-branch | spec]
---

# cleanup — post-merge spec teardown

Run this **once per spec**, after its feature branch's PR is merged, to reclaim everything the work left behind: the worktree it lived in, the feature branch, the per-worktree scratch DB, and a primary checkout left sitting on a fresh trunk. It also closes the spec issue — the last of the three closures.

**Spec-scoped, not ticket-scoped.** Tickets need no teardown: `/ticket-done` already squash-merged each task branch and deleted it, and nothing was ever provisioned per ticket. The worktree, the env, the ports, and the DB were all provisioned **once** by `/implement` Step 0 and shared by every ticket in the spec, so they are reclaimed **once**, here.

Destructive — it removes a worktree and deletes branches — so the merged-state gate below is mandatory. When the PR is still open, this skill stops.

**Trunk** = the branch this repo merges into, recorded by `/setup-skills` under delivery shape (`develop` on a git-flow repo, `main` otherwise). Fall back to the default branch (`git symbolic-ref refs/remotes/origin/HEAD`) only when nothing is recorded. Teardown that hardcodes `main` on a `develop` repo leaves the primary stale and the next worktree branched off the wrong base.

You cannot remove a worktree you are standing in, and you cannot delete a branch that is currently checked out. Run every git command with `-C <primary>` (the primary checkout), or `cd` there first.

## Identify scope

- **Target** from `$ARGUMENTS` — a worktree path, a feature branch, or a spec that maps to one. Else infer from context (the worktree you were just working in, or the current branch).
- List worktrees: `git worktree list`. Record the **primary checkout** (the non-worktree entry, usually sitting on the trunk).
- **Trunk** — read it from the delivery shape `/setup-skills` recorded.
- **Feature branch** — the `<type>/<feature>` stem. Its task branches (`<type>/<feature>-<NN>-*`) should already be gone; `git branch --list '<type>/<feature>-*'` catching any survivor means a `/ticket-done` didn't finish. Surface it rather than deleting silently.

Completion: you can name the feature branch, the worktree holding it and its path, the primary checkout, and the trunk — before touching anything.

## Gate: confirm the work is MERGED

Do **not** destroy anything until the feature branch has landed:

```bash
gh pr list --head <feature-branch> --state merged --json number,url,mergedAt
```

- Merged → proceed.
- Still **open** (or no merged PR exists) → stop and say so. Only override on explicit user instruction (e.g. branch abandoned, intentionally never merged) — and say so in the report.

## Close the spec issue

The feature has landed, so the spec — the unit of delivery — is done. This is where it closes; nothing earlier can, because `/spec-done` deliberately stops at opening the PR.

```bash
gh pr view <n> --json body --jq '.body | scan("[Cc]loses #[0-9]+")'
gh issue view <n> --json number,state
```

Close anything still open — `gh issue close <n> --reason completed` — and **name it in the report**. `Closes #<n>` fires automatically only when the PR merges into the repository's **default branch**, so on a git-flow repo (trunk `develop`, default `main`) *nothing* the pipeline merges ever closes an issue by keyword. Treat closing by hand here as the normal path, not an exception.

Ticket issues should already be closed by `/ticket-done`. Any still open is a signal a ticket never finished — surface it rather than closing it silently.

On a **local markdown** tracker there is nothing to reconcile: `/ticket-done` set each ticket file's Status to `done`; set the spec file's Status to `done` here.

Completion: the spec issue is closed, and any ticket issue that survived to here is named in the report.

## Teardown

Order matters: a branch can't be deleted while a worktree has it checked out, so free it first.

**1. Remove the worktree.** Post-merge the working tree should be clean:
```bash
git -C <primary> worktree remove <worktree-path>
```
If git refuses (uncommitted changes or untracked files left behind), **stop and surface it** — don't reach for `--force`; the user may have unsaved work there.

**2. Delete the local feature branch.** Squash-merge rewrites history, so `git branch -d` reports "not fully merged" and refuses; the merged-state gate already confirmed the PR landed, so force-delete is the correct call:
```bash
git -C <primary> branch -D <feature-branch>
```
Also sweep any surviving task branch you flagged during scoping.

**3. Delete the remote branch** if it still exists (many repos auto-delete on merge):
```bash
git -C <primary> ls-remote --exit-code --heads origin <feature-branch> >/dev/null 2>&1 \
  && git -C <primary> push origin --delete <feature-branch> || echo "remote branch already gone"
```

**4. Prune stale worktree metadata:** `git -C <primary> worktree prune`.

## Refresh the primary checkout

Leave the primary sitting on the merged trunk, ready for the next worktree to branch off it:
```bash
git -C <primary> checkout <trunk> && git -C <primary> pull --ff-only
```
`--ff-only` keeps it honest — if the primary has local divergence it errors instead of forging a merge commit; surface that rather than papering over it.

## Per-worktree teardown hooks

`/implement` Step 0 may have provisioned more than a branch — a scratch DB, generated artifacts — that outlives it. Everything here is **per worktree**, matching what setup created, and runs once:

- **Scratch database** — the per-worktree dev DB (`myapp_<suffix>`) cloned at provisioning, shared by every ticket in the spec. Drop it: `psql -d postgres -c 'DROP DATABASE IF EXISTS <name> WITH (FORCE);'` (`FORCE` terminates lingering connections so the drop doesn't block). Its name lives in the worktree's `.env` — read it *before* removing the worktree, or you'll lose the pointer.
- **Cleanup script** — if the repo ships one (`scripts/cleanup*.sh`, a `make teardown` target), prefer it over hand-rolled steps.
- **Docker stack** — if the repo ships a compose file, run the [Docker teardown](docker.md): sort artifacts into **keyed** (this worktree's, destroy) and **dangling** (untagged images, anonymous volumes — report, then reclaim on the user's go-ahead). Almost nothing is keyed by default, so this hook is mostly the dangling pass; a keyed stack must come down *before* the worktree is removed.
- **Other per-worktree artifacts** — temp files and generated output keyed to the feature. Remove what the setup created; leave shared infrastructure alone.
- **Post-merge migration on primary** — if the merged branch added a schema migration and the primary dev DB never applied it, apply it now so the next session doesn't break on a missing column. Report failures, don't force-fix.

If you find no such setup, say so — skipping a hook the repo doesn't use is the right outcome, not an omission.

## Report

Trunk · PR merged-state · spec issue closed (and any ticket issue that shouldn't have survived) · worktree removed (path) · branches deleted (local / remote, or "remote already gone") · surviving task branches, if any · DB / hooks dropped or skipped-why · Docker: keyed stack torn down or n/a, dangling reclaimed (size) or awaiting go-ahead · primary refreshed to `<trunk>` (new HEAD). Call out anything skipped — PR still open, dirty worktree, non-ff trunk — so nothing is silently left behind.
