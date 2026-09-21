---
name: ship
description: "Ship the current branch as a PR: rebase or merge the base, run the full suite, push, and open or update the PR with a body written by /pr. Use when every ticket of a spec is done (from /dispatch or by hand), or for any branch that is ready for review. Never merges."
argument-hint: [spec] [checkout]
---

# ship — one branch, one PR

`/ship` lands a branch on the remote as a pull request. Ship owns the git that leaves the machine; `/pr` owns the body; the merge stays the human's. Post-merge teardown is `/cleanup`.

## Vocabulary

- **Trunk**: the branch the repo merges into (`develop` on a git-flow repo, `main` otherwise); same rule as `/cleanup`.
- **Base**: the branch the PR targets. The trunk for a new PR, the PR's own `baseRefName` for one that exists.
- **Checkout**: the working tree ship runs in. The cwd by default; `/dispatch` passes the spec worktree. Every git and gh command runs there, `git -C <checkout>` and `gh` from inside it.
- **Spec**: the first of `$ARGUMENTS`, or the `<spec-number>` in a `<type>/<spec-number>-<slug>` branch name, resolved on the tracker (`docs/agents/issue-tracker.md`). A branch with no spec ships as a plain change.

## 1. Preflight

- Head is not the trunk or the default branch.
- `git status --porcelain` is empty. Uncommitted work goes back to `/implement`, which commits.
- With a spec: list its tickets from the tracker. Every ticket is closed (`Status: done` locally). Any open ticket stops the run and names it; `/dispatch` or the human finishes it first.

Completion: on a clean non-trunk branch, with every spec ticket closed.

## 2. Fetch and read the base

`git fetch --all --prune`. Then `gh pr view --json number,url,baseRefName,state`:

- A PR exists: the branch is **under review**; base = its `baseRefName`.
- No PR: the branch is **new**; base = the trunk.

Completion: one line states `head ← base` and whether the branch is new or under review.

## 3. Integrate the base

`git rev-list --count HEAD..origin/<base>` greater than zero means the base moved. Zero: skip to step 4.

- **New**: `git rebase origin/<base>`. No review threads exist yet, so take the linear history.
- **Under review**: `git merge origin/<base>`. A rebase discards review threads and approvals.

On conflict run `/resolving-merge-conflicts`; finish the operation, never abort it.

Completion: `git rev-list --count HEAD..origin/<base>` is zero.

## 4. Full suite

Run the repo's complete suite, plus typecheck and lint where the repo has them. Each ticket ran the suite on its own commit; this run proves the combination on top of the moved base.

Red: stop. Report the failing test and leave the branch unpushed. Fix on the branch, commit, and run `/ship` again.

Completion: green.

## 5. Push

- No `origin/<head>` yet: `git push -u origin <head>`.
- After a rebase: `git push --force-with-lease`. It aborts when the remote moved after the fetch.
- Otherwise: `git push`.

Completion: `origin/<head>` equals local `HEAD`.

## 6. Write the body

Invoke the `pr` skill on `git diff <base>...HEAD` and `git log <base>..HEAD`. With a spec, add two things to what `/pr` produces:

- `Closes #<spec>` under the Summary, so the spec issue closes on merge. `/cleanup` closes it by hand when the trunk is not the default branch.
- A `## Tickets` table after the Summary: one row per ticket with its ref, title, and closing commit (`git log <base>..HEAD --grep '<ticket ref>'`).

Completion: a body with Summary, Evidence and Merge Danger, plus Tickets and the closing keyword when there is a spec.

## 7. Open or update the PR

- **New**: `gh pr create --base <base> --head <head> --title "<title>" --body-file <body>`. Spec title: `#<spec>: <spec title>`. Otherwise the first commit subject.
- **Under review**: `gh pr edit <n> --body-file <body>`. Keep the existing title.

Completion: exactly one open PR for head, targeting base, whose body is the record.

## Report

`<head> ← <base>` · new or under review · rebased, merged, or already current · suite result · pushed · PR URL, created or updated.
