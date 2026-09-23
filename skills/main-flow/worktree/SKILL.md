---
name: worktree
description: "Put code work in its own provisioned linked worktree: find the worktree that holds the branch or create one, run scripts/provision.sh, and share or fork the database from the spec's Schema changes line. Use before /implement or /dispatch writes code, and before you add a migration in a worktree that shares the database."
argument-hint: [branch | spec | ticket]
---

# worktree: one spec, one provisioned checkout

Code work runs in a linked worktree. One worktree holds one spec. The primary checkout stays free for planning and for changes to docs only.

This skill keys on git facts only. A worktree made by Herdr, by `git worktree add`, or by this skill resolves the same way.

## Vocabulary

- **Primary**: the checkout whose git dir is the common dir. `git rev-parse --absolute-git-dir` equals `git rev-parse --path-format=absolute --git-common-dir`.
- **Linked worktree**: any other checkout of the same repo, wherever it lives.
- **Trunk**: the branch the repo merges into (`develop` on a git-flow repo, `main` otherwise); same rule as `/cleanup`.
- **Branch**: the spec branch, `<type>/<spec-number>-<spec-slug>` off the trunk. A ticket with no parent spec gets `<type>/<ticket-number>-<slug>`. A branch that already exists keeps its name.

## 1. Locate

Read `git worktree list --porcelain` and where you stand. Take the one matching case:

- In a linked worktree whose branch is the target, or carries the spec or ticket number: stay. A hand-made worktree keeps its branch name; that name is the branch from here on.
- In a linked worktree on any other branch: stop and say so. That worktree belongs to other work.
- In the primary, and a worktree holds the branch: `EnterWorktree` on its path.
- In the primary, and nothing holds the branch: create the worktree, then `EnterWorktree` on it. With `herdr` on PATH, `herdr worktree create --branch <branch> --base <trunk>`, so it lands beside the hand-made ones. Otherwise `git worktree add -b <branch> .claude/worktrees/<slug> <trunk>`, without `-b` when the branch exists.
- In the primary, and the primary itself has the branch checked out: stop and say so. A branch is checked out in one place only.

Completion: the session stands in a linked worktree that has the branch checked out.

## 2. Provision

`scripts/provision.sh` exists: run it. It is idempotent, so a provisioned worktree costs one no-op run. Red: report the tail and stop. Nothing works in a worktree that failed to provision.

No script, and the repo has gitignored `.env*` files, a dependency lockfile, or a database URL in an env file: say `Run /setup-worktrees` and stop.

No script, and the repo has none of those: nothing to provision. Skip step 3.

Completion: the script ran green, or the repo needs no provisioning.

## 3. Database

The tail of the script has no `db` line: the repo has no database. Skip this step.

Find the `Schema changes:` line. It is in the Implementation Decisions of the spec. A ticket with no parent spec carries its own line. With no spec and no ticket, ask the human once: does this work change the schema?

- The line lists migrations: run `scripts/provision.sh db fork`.
- The line says `none`: keep the shared database.
- There is no line, or no answer: run `scripts/provision.sh db fork`. This is the safe default.

Completion: the `db` line in the tail agrees with the rule. A fork shows `<db>_<branch>`; a share shows `(shared)`.

## While you work

The shared database is the primary's. A migration applied to it changes the schema under the primary and every other worktree. Before you create a migration in a worktree whose `db` line shows `(shared)`, run `scripts/provision.sh db fork`. The database URL changes, so restart the dev servers that run from this worktree.

## Report

`<path> · <branch> · found | created · provisioned | nothing to provision · db shared | forked <name> | none`
