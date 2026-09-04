---
name: cleanup
description: "Post-merge teardown for a landed spec — confirm the spec branch landed, verify the spec issue and its tickets closed, then reclaim what the work left on your machine: the worktree, the branches, the per-worktree scratch DB, Docker leftovers, stale metadata, and a refreshed trunk."
disable-model-invocation: true
argument-hint: [worktree-path | spec-branch | spec]
---

# cleanup — post-merge spec teardown

One spec = one worktree, one branch off the trunk, landed by the human. Tickets are commits on that branch, closed by `/dispatch` as they land. Run this once per spec after the branch lands: verify the spec issue and its tickets closed, then reclaim everything provisioned for that worktree — worktree, branches, scratch DB, Docker leftovers — and leave the primary checkout on a fresh trunk.

**Trunk** = the branch this repo merges into (`develop` on a git-flow repo, `main` otherwise). Default to the default branch (`git symbolic-ref refs/remotes/origin/HEAD`); a repo carrying both `main` and `develop` is running git-flow, so the trunk is `develop`. Teardown that hardcodes `main` on a `develop` repo leaves the primary stale and the next worktree branched off the wrong base.

You cannot remove a worktree you are standing in, and you cannot delete a branch that is currently checked out. Run every git command with `-C <primary>` (the primary checkout), or `cd` there first.

## Identify scope

- **Target** from `$ARGUMENTS` — a worktree path, a spec branch, or a spec that maps to one. Else infer from context (the worktree you were just working in, or the current branch).
- List worktrees: `git worktree list`. Record the **primary checkout** (the non-worktree entry, usually sitting on the trunk).
- **Trunk** — per the rule above; confirm with the user if ambiguous.
- **Spec branch** — `<type>/<spec-number>-<slug>`, the spec's only branch, held by the target worktree (created by `/implement` on the spec's first ticket).

Completion: you can name the spec branch, the worktree holding it and its path, the primary checkout, and the trunk — before touching anything.

## Gate: confirm the work LANDED

Nothing is destroyed until the spec branch is on the trunk. A spec lands either through a PR or by a direct merge, so take whichever signal exists:

```bash
gh pr list --head <spec-branch> --state merged --json number,url,mergedAt   # if the spec went through a PR
git -C <primary> log <trunk> --oneline --grep '<spec-number>' | head        # commits from the branch, on the trunk
```

(GitLab: `glab mr list` equivalents per the tracker doc, here and throughout.)

- A merged PR, or the branch's commits present on the trunk → proceed.
- Neither, or a PR still **open** → stop and say so. Squash-merges rewrite hashes and defeat both checks, so where the trunk was squashed, the user's confirmation that the branch landed is the gate. Only override on explicit user instruction (e.g. branch abandoned, intentionally never merged) — and say so in the report.

## Verify the spec issue and its tickets closed

`/dispatch` closes each ticket as it commits, and `/ship` closes the spec issue when it opens the PR, so this is normally a verification pass. A spec driven by hand instead relies on `Closes #<spec>` plus one `Closes #<ticket>` per ticket in the PR body, and that keyword fires only when the PR merges into the repository's **default branch**:

```bash
gh pr view <n> --json body --jq '.body | scan("[Cc]loses #[0-9]+")'
gh issue view <n> --json number,state          # for the spec and each ticket
```

List the spec's tickets from the tracker (sub-issues of the spec, or its "Blocked by" graph) so a ticket missing from the PR body is not missed.

- Driven by `/dispatch` and `/ship`, or trunk **is** the default branch → the issues should already be closed. Verify rather than assume — a ticket dispatch parked, or a PR body that lost a keyword, leaves that issue open silently.
- Trunk is `develop` but the default branch is `main` → the keywords never fired; closing by hand here is the normal path, not an exception.

Close anything still open — `gh issue close <n> --reason completed` — tickets first, then the spec, and **name each one in the report**. On a **local markdown** tracker: set every ticket file's Status to `done`, then mark the spec file `done`.

Completion: every ticket and the spec issue are closed, and the report says which closed by keyword and which by hand.

## Teardown

Order matters: a branch can't be deleted while a worktree has it checked out, so free it first. Read the worktree's `.env` (scratch DB name) and bring down any Docker containers launched from inside it *before* step 1 — see the hooks below.

**1. Remove the worktree.** Post-merge the working tree should be clean:
```bash
git -C <primary> worktree remove <worktree-path>
```
If git refuses (uncommitted changes or untracked files left behind), **stop and surface it** — the user may have unsaved work there.

**2. Delete the local spec branch.** Squash-merge rewrites history, so `git branch -d` reports "not fully merged" and refuses; the merged-state gate already confirmed the PR landed, so force-delete is the correct call:
```bash
git -C <primary> branch -D <spec-branch>
```

**3. Delete the remote branch** if it still exists (many repos auto-delete on merge):
```bash
git -C <primary> ls-remote --exit-code --heads origin <spec-branch> >/dev/null 2>&1 \
  && git -C <primary> push origin --delete <spec-branch> || echo "remote branch already gone"
```

**4. Prune stale worktree metadata:** `git -C <primary> worktree prune`.

## Refresh the primary checkout

Leave the primary sitting on the merged trunk, ready for the next worktree to branch off it:
```bash
git -C <primary> checkout <trunk> && git -C <primary> pull --ff-only
```
`--ff-only` errors on local divergence instead of forging a merge commit; surface that rather than papering over it.

## Per-worktree teardown hooks

Provisioning may have created more than a branch. Everything here is **per worktree**, matching what `scripts/provision.sh` created, and runs once:

- **Scratch database** — the per-worktree dev DB (`myapp_<suffix>`) cloned at provisioning. Drop it: `psql -d postgres -c 'DROP DATABASE IF EXISTS <name> WITH (FORCE);'` (`FORCE` terminates lingering connections so the drop doesn't block). Its name lives in the worktree's `.env` — read it *before* removing the worktree, or you'll lose the pointer. A worktree that shared the main dev DB (no `provision.sh db`) has nothing to drop.
- **Cleanup script** — if the repo ships one (`scripts/cleanup*.sh`, a `make teardown` target), prefer it over hand-rolled steps.
- **Docker stack** — if the repo ships a compose file, run the [Docker teardown](docker.md): sort artifacts into **keyed** (this worktree's, destroy) and **dangling** (untagged images, anonymous volumes — report, then reclaim on the user's go-ahead). Almost nothing is keyed by default, so this hook is mostly the dangling pass; a keyed stack must come down *before* the worktree is removed.
- **Other per-worktree artifacts** — temp files and generated output keyed to the spec. Remove what the setup created; leave shared infrastructure alone.
- **Post-merge migration on primary** — if the merged branch added a schema migration and the primary dev DB never applied it, apply it now so the next session doesn't break on a missing column. Report failures, don't force-fix.

If you find no such setup, say so — skipping a hook the repo doesn't use is the right outcome, not an omission.

## Report

Trunk · how the branch landed (merged PR, or commits on trunk) · tickets closed (N by keyword, M by hand, listed) · spec issue closed (by keyword or by hand) · worktree removed (path) · branches deleted (local / remote, or "remote already gone") · DB / hooks dropped or skipped-why · Docker: keyed stack torn down or n/a, dangling reclaimed (size) or awaiting go-ahead · primary refreshed to `<trunk>` (new HEAD). Call out anything skipped — PR still open, dirty worktree, open tickets, non-ff trunk — so nothing is silently left behind.
