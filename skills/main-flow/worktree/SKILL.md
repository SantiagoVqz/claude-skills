---
name: worktree
description: "Give a branch its own provisioned linked git worktree: find the worktree that already holds the branch or create one off the trunk, then run the repo's scripts/provision.sh in it. Use when a skill needs a branch in its own worktree, or a fresh worktree lacks env files, dependencies, or its own database."
argument-hint: [branch]
---

# worktree — one branch, one provisioned checkout

`/worktree <branch>` gives a branch its own linked worktree, provisioned. `/worktree` alone provisions the worktree you stand in. Herdr, `claude --worktree`, and `git worktree add` all make linked worktrees; this skill keys on the git fact and nothing else.

Provisioning is the repo's job: `scripts/provision.sh` copies env files from the primary checkout, installs dependencies, and forks a database when the repo has one. It is idempotent, so running it is the check that a worktree is provisioned. Humans never call this skill before working: the session hook runs the script on its own. `/dispatch` calls it because subagents run inside a session that is already open in the primary.

## Vocabulary

- **Primary**: the checkout whose git dir is the common dir. `git rev-parse --absolute-git-dir` equals `git rev-parse --path-format=absolute --git-common-dir`.
- **Linked worktree**: any other checkout of the same repo, wherever it lives.
- **Trunk**: the branch the repo merges into (`develop` on a git-flow repo, `main` otherwise); same rule as `/cleanup`.

## 1. Locate

With a branch: `git worktree list --porcelain`. A worktree already holds the branch: use it, wherever it is. None: from the primary, `git worktree add .claude/worktrees/<slug> <branch>`, with `-b <branch> <trunk>` when the branch does not exist yet. Add `.claude/worktrees/` to `.git/info/exclude` when it is missing, so the primary's `git status` stays clean.

Without a branch: the cwd must be a linked worktree. In the primary, stop and say so; the primary is never provisioned.

Completion: a path to a linked worktree with the branch checked out.

## 2. Provision

`scripts/provision.sh` exists and is executable: run it in the worktree. Red: report the tail and stop. Nothing works in a worktree that failed to provision.

Missing, and the repo has gitignored `.env*` files, a dependency lockfile, or a database URL in an env file: the repo is not set up. Say `Run /setup-skills; its worktree section installs scripts/provision.sh and the session hook` and stop.

Missing, and the repo has none of those: nothing to provision. Continue.

Completion: the script ran green, the repo needs no provisioning, or the human was sent to `/setup-skills`.

## Report

`<path> · <branch> · found | created · provisioned | nothing to provision | not set up, run /setup-skills`
