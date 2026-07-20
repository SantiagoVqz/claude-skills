---
name: ship
description: "Push the current branch and open its PR (or report the existing one) — the external-git half of the build lifecycle, run after /implement has committed and reviewed. Rebases a new branch onto its base; follows repo policy for a branch already under review."
disable-model-invocation: true
argument-hint: [base]
---

# Ship

Take a committed, reviewed branch and **land it on the remote as a pull request** — nothing more. `/implement` owns the code, tests, review, and commits; `ship` owns the git that leaves the machine: reconcile, push, PR. It never merges the PR — that stays the human's call.

The lifecycle is two commands:

```
/implement <ticket or spec>
/ship
```

## Step 1 — Preflight gate

- **Head** = current branch (`git rev-parse --abbrev-ref HEAD`). It must **not** be the default branch (`git symbolic-ref refs/remotes/origin/HEAD`) — refuse to ship from `main`.
- **Clean tree.** `git status --porcelain` must be empty. `ship` publishes committed work; it does not commit. If dirty, stop and send the user back to `/implement`.

Completion: on a feature branch with an empty status.

## Step 2 — Fetch and read the base

- `git fetch --all --prune` so base and PR state reflect the remote, not a stale local copy.
- **Existing PR?** `gh pr view --json number,url,baseRefName,reviewDecision,state`. This one call sets the branch's status for every step below:
  - a PR exists → the branch is **under review**; its **base** = the PR's `baseRefName`.
  - no PR → the branch is **new**; its **base** = `$ARGUMENTS` if given, else the default branch.

Completion: you can state `head ← base` and whether the branch is new or under review, in one line.

## Step 3 — Integrate the base, only if behind

- Behind? `git rev-list --count <head>..origin/<base>` greater than 0 means the base moved ahead. If 0, skip to Step 4.
- If behind, hand off to **/reconcile-branch** with the directive that follows from Step 2's status:
  - **new branch → require a rebase.** An unreviewed branch has no approvals to preserve, so rebase for a clean, linear history.
  - **under review → repo policy.** `/reconcile-branch` defaults to merging the base into a reviewed branch, preserving review threads and approvals. Don't override it.

Completion: `git rev-list --count <head>..origin/<base>` is 0 — the branch contains the base.

## Step 4 — Push

Publish head to origin:

- **new remote branch** (no `origin/<head>` yet): `git push -u origin <head>`.
- **after a rebase**: `git push --force-with-lease` — never plain `--force`; `--with-lease` aborts if the remote moved since your fetch.
- **otherwise**: `git push`.

If `/reconcile-branch` already pushed in Step 3, this only confirms `origin/<head>` matches local — a fast no-op is the right outcome, not a redundant push.

Completion: `origin/<head>` equals local `<head>`.

## Step 5 — PR

- **PR exists** (Step 2) → report its URL; don't recreate. If Step 3 changed the branch, note it's updated.
- **No PR** → create a focused one: `gh pr create --base <base> --head <head>`. Title and body describe *this branch's* change only — a tight summary plus the ticket/spec it closes — not a blow-by-blow of the work.

Completion: exactly one open PR for head, targeting base.

## Never

- **Never merge the PR** — `ship` lands the branch for review; the merge stays the human's call. Post-merge teardown is `/cleanup`.
- **Never `git push --force`** — only `--force-with-lease`, and only after a rebase.
- **Never ship a dirty tree** — send unfinished work back to `/implement`.
- **Never rebase a branch under review** — it discards approvals and review context; that's why the reviewed-branch default is merge.

## Report

`head ← base` · new or under-review · integrated y/n (rebase/merge, via /reconcile-branch) · pushed y/n · PR URL (created or existing) · final base/head status.
