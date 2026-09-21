---
name: cleanup
description: "Post-merge teardown for a landed spec: confirm the spec branch landed, verify the spec issue and its tickets closed, delete the local and remote branches, and leave the checkout on a refreshed trunk."
disable-model-invocation: true
argument-hint: [spec-branch | spec]
---

# cleanup — post-merge spec teardown

One spec = one branch off the trunk, landed by the human. Tickets are commits on that branch, closed by `close-ticket` as they land. Run this once per spec after the branch lands.

**Trunk** = the branch this repo merges into (`develop` on a git-flow repo, `main` otherwise). Default to the default branch (`git symbolic-ref refs/remotes/origin/HEAD`); a repo carrying both `main` and `develop` is running git-flow, so the trunk is `develop`. Teardown that hardcodes `main` on a `develop` repo leaves the checkout stale and the next branch off the wrong base.

## Identify scope

- **Target** from `$ARGUMENTS`: a spec branch, or a spec that maps to one. Else infer from context: the current branch, or the one you were just working on.
- **Spec branch**: `<type>/<spec-number>-<slug>`, the spec's only branch, created by `/dispatch` or by hand.
- **Trunk**: per the rule above; confirm with the user if ambiguous.

Completion: you can name the spec branch and the trunk before touching anything.

## Gate: confirm the work landed

Nothing is deleted until the spec branch is on the trunk. A spec lands either through a PR or by a direct merge, so take whichever signal exists:

```bash
gh pr list --head <spec-branch> --state merged --json number,url,mergedAt   # if the spec went through a PR
git log <trunk> --oneline --grep '<spec-number>' | head                       # commits from the branch, on the trunk
```

(GitLab: `glab mr list` equivalents per the tracker doc.)

- A merged PR, or the branch's commits present on the trunk: proceed.
- Neither, or a PR still **open**: stop and say so. Squash-merges rewrite hashes and defeat both checks, so where the trunk was squashed, the user's confirmation that the branch landed is the gate. Only override on explicit user instruction, and say so in the report.

## Verify the spec issue and its tickets closed

`close-ticket` closes each ticket as it commits, and `/ship` puts `Closes #<spec>` in the PR body, so this is normally a verification pass. That keyword fires only when the PR merges into the repository's **default branch**:

```bash
gh pr view <n> --json body --jq '.body | scan("[Cc]loses #[0-9]+")'
gh issue view <n> --json number,state          # for the spec and each ticket
```

List the spec's tickets from the tracker (sub-issues, or issues whose Parent names the spec; `.scratch/<slug>/issues/*.md` locally) so a ticket missing from the PR body is not missed.

- Trunk **is** the default branch: the issues should already be closed. Verify rather than assume. A ticket the human finished by hand, or a PR body that lost a keyword, leaves that issue open silently.
- Trunk is `develop` but the default branch is `main`: the keywords never fired; closing by hand here is the normal path.

Close anything still open, `gh issue close <n> --reason completed`, tickets first, then the spec, and **name each one in the report**. On a **local markdown** tracker: set every ticket file's Status to `done`, then mark the spec file `done`.

Completion: every ticket and the spec issue are closed, and the report says which closed by keyword and which by hand.

## Teardown

You cannot delete a branch that a worktree has checked out. A spec branch lives in its own linked worktree (`git worktree list`), provisioned by `scripts/provision.sh` where the repo has one. Run this from the primary checkout; standing in the spec worktree, `ExitWorktree` first.

```bash
(cd <worktree> && scripts/provision.sh db drop)   # only if the script exists: the forked database goes with the worktree
git worktree remove <worktree>                     # refuses on uncommitted or untracked files: stop and surface it, never --force
git checkout <trunk> && git pull --ff-only
git branch -D <spec-branch>                    # -D: a squash-merge makes -d refuse; the gate above already proved it landed
git ls-remote --exit-code --heads origin <spec-branch> >/dev/null 2>&1 \
  && git push origin --delete <spec-branch> || echo "remote branch already gone"
```

A spec branch with no worktree skips the first two lines.

`--ff-only` errors on local divergence instead of forging a merge commit; surface that rather than papering over it. If the merged branch added a schema migration and the local dev DB never applied it, apply it now so the next session doesn't break on a missing column. Report failures, don't force-fix.

## Report

Trunk · how the branch landed (merged PR, or commits on trunk) · tickets closed (N by keyword, M by hand, listed) · spec issue closed (by keyword or by hand) · worktree removed (path) or n/a · database dropped or n/a · branches deleted (local / remote, or "remote already gone") · trunk refreshed (new HEAD) · migration applied or n/a. Call out anything skipped, PR still open, open tickets, dirty worktree, non-ff trunk, so nothing is silently left behind.
