---
name: ship
description: "Rebase the current ticket branch onto the trunk, run the full test suite, push, and open its PR — run after /implement has committed. Never merges."
disable-model-invocation: true
argument-hint: [base]
---

# Ship

Take a committed, reviewed ticket branch and **land it on the remote as a pull request** — nothing more. `/implement` owns the code, tests, and commits; `ship` owns the git that leaves the machine: rebase, verify, push, PR. It never merges the PR — that stays the human's call.

The per-ticket lifecycle is:

```
/implement <ticket>   # in the ticket's worktree
/ship                 # rebase → suite → push → PR
# human merges the PR
/cleanup              # teardown: worktree, branch, DBs
```

## Step 1 — Preflight gate

- **Head** = current branch (`git rev-parse --abbrev-ref HEAD`). It must **not** be the default branch (`git symbolic-ref refs/remotes/origin/HEAD`) — refuse to ship from the trunk.
- **Clean tree.** `git status --porcelain` must be empty. `ship` publishes committed work; it does not commit. If dirty, stop and send the user back to `/implement`.

Completion: on a ticket branch with an empty status.

## Step 2 — Fetch and read the base

- `git fetch --all --prune` so base and PR state reflect the remote, not a stale local copy.
- **Existing PR?** `gh pr view --json number,url,baseRefName,reviewDecision,state`:
  - a PR exists → the branch is **under review**; its **base** = the PR's `baseRefName`.
  - no PR → the branch is **new**; its **base** = `$ARGUMENTS` if given, else the default branch.

Completion: you can state `head ← base` and whether the branch is new or under review, in one line.

## Step 3 — Rebase onto the base, only if behind

- Behind? `git rev-list --count <head>..origin/<base>` greater than 0 means the base moved ahead. If 0, skip to Step 4.
- **New branch → rebase**: `git rebase origin/<base>`. No approvals exist to preserve, so buy the clean linear history. Conflicts → `/resolving-merge-conflicts` (finish the rebase, never `--abort`).
- **Under review → merge the base in** (`git merge origin/<base>`) — a rebase discards review threads and approvals.

Completion: `git rev-list --count <head>..origin/<base>` is 0 — the branch contains the base.

## Step 4 — Full test suite

Only if Step 3 integrated something. The point is proving the combination, not re-proving the branch — `/implement` already ran the suite on the branch alone. Step 3 skipped means nothing moved underneath you; skip to Step 5.

Otherwise run the repo's complete suite (plus typecheck/lint if the repo has them) on the post-rebase head. Red → stop. Fix on the branch (back through `/implement` for anything non-trivial), commit, re-run. Never ship red.

Completion: base integrated and suite green, or Step 3 skipped.

## Step 5 — Push

- **New remote branch** (no `origin/<head>` yet): `git push -u origin <head>`.
- **After a rebase**: `git push --force-with-lease` — never plain `--force`; `--with-lease` aborts if the remote moved since your fetch.
- **Otherwise**: `git push`.

Completion: `origin/<head>` equals local `<head>`.

## Step 6 — PR

- **PR exists** (Step 2) → report its URL; don't recreate. If Step 3 changed the branch, note it's updated.
- **No PR** → `gh pr create --base <base> --head <head>`. Title and body describe *this ticket's* change only — a tight summary plus `Closes #<ticket>` so the ticket issue closes itself when the PR merges into the default branch.

Completion: exactly one open PR for head, targeting base, carrying `Closes #<ticket>`.

## Never

- **Never merge the PR** — the merge stays the human's call. Post-merge teardown is `/cleanup`.
- **Never `git push --force`** — only `--force-with-lease`, and only after a rebase.
- **Never ship a dirty tree or a red suite.**
- **Never rebase a branch under review** — merge the base instead.

## Report

`head ← base` · new or under-review · rebased/merged/already-current · suite result · pushed y/n · PR URL (created or existing).
