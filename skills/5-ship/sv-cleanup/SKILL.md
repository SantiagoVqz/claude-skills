---
name: sv-cleanup
description: "Tear down a merged spec or fix branch: check the merged PR, close the issues, remove the worktree and branches, and refresh the trunk."
disable-model-invocation: true
argument-hint: "[spec | issue]"
---

# Cleanup

`/sv-cleanup` runs after the user merges a PR from `/sv-ship`. It ends with the issues in the right state, the worktree and branches gone, and the primary checkout on the latest trunk. It deletes nothing before the gate passes.

Run it from the primary checkout. When the session is in a worktree, call `ExitWorktree` with `keep` first. When `ExitWorktree` says that no session is active, the session went into the worktree with `cd`: run `cd` to the first path of `git worktree list`, which is the primary checkout. When the session is still not in the primary checkout, stop, and tell the user to run `/sv-cleanup` in a session there.

## 1. Find

The target is the argument, or the branch you just shipped: `spec/<n>-<slug>` or `fix/<n>-<slug>`. Find the trunk as the `sv-worktree` skill does.

Completion: you have the branch, its issue and the trunk.

## 2. Gate

Run `gh pr list --head <branch> --state all --json number,url,state,body`.

- **A merged PR**: go on. Read its merge commit with `gh pr view <pr> --json mergeCommit`. When that commit has two parents (`git cat-file -p <commit>` after a fetch), the PR merged with a merge commit, not rebase and merge. Name it in the report. Name the repo setting that blocks it, `gh repo edit --enable-merge-commit=false`, only when the trunk is not `develop` and no ADR in `docs/adr/` needs merge commits. A release flow from `develop` to `main` can need them.
- **An open PR**: stop, and give its URL.
- **No PR**: stop. The next step is `/sv-ship`.

Completion: the branch has a merged PR.

## 3. Issues

Read the closing line of the PR body.

- **`Closes #<n>`**: read the issue and, for a spec, each of its tickets. Close each one that is still open, as `tracker.md` says: the tickets first, then the spec. The keyword fires only on a merge into the default branch, so when the trunk is not the default branch, a close by hand is the normal path.
- **`Part of #<spec>`**: a partial ship. The spec and its open tickets stay open.

Completion: each issue is in the state that the closing line gives, and you know which closed by keyword and which by hand.

## 4. Servers

Stop each dev server and background task that runs from the worktree. Check the background tasks of this session, and each process whose working directory is in the worktree: `lsof -d cwd` lists them. A task can survive a `/clear`, so look also when you think this session started none.

Completion: no process has its working directory in the worktree.

## 5. Worktree

Call the Skill tool with `sv-worktree` to remove the worktree of the branch. When the primary checkout has the branch and no worktree has it, run `git switch <trunk>`, then `git branch -D <branch>`, and skip `sv-worktree`. Ticket worktrees of the spec stay. The next `/sv-build` on such a ticket makes a new spec branch and rebases the ticket onto it.

Completion: `git worktree list` does not show the branch, and the local branch is gone.

## 6. Remote branch

Run `git ls-remote --exit-code --heads origin <branch>`. When the branch is there, run `git push origin --delete <branch>`. GitHub can delete it on merge, so a missing branch is normal.

Completion: origin does not have the branch.

## 7. Trunk

Record the trunk head with `git rev-parse HEAD`. Run `git pull --ff-only`.

When it does not fast-forward, list the local-only commits with `git log --oneline origin/<trunk>..<trunk>`. Ask with the question tool:

- **Move to a branch** (recommended): `git branch local/<trunk>-<date> <trunk>`, then `git reset --keep origin/<trunk>`. The commits stay on the branch, and the user ships them with a PR.
- **Rebase and push**: `git rebase origin/<trunk>`, then `git push origin <trunk>`. Only for a repo where the user pushes to the trunk.
- **Stop**: keep everything as it is.

Completion: the primary checkout is on the latest trunk, or the user picked Stop.

## 8. Migrations

Find the migration folder in `AGENTS.md`, or in the config of the migration tool, such as `script_location` in `alembic.ini`. Run `git diff --name-only <old head> HEAD -- <folder>`. When it shows new migrations, run the migrate command from `AGENTS.md` or `package.json` on the trunk dev database. When the repo has no such command, name the migrations in the report.

Completion: the trunk dev database has each new migration, or the report names them.

## Excuses

| Excuse | Answer |
|---|---|
| "The worktree was made by hand, so I remove it by hand." | Call the `sv-worktree` skill. Its Remove also drops the test database. |

Add a row only when `/sv-retro` finds a new excuse.

## Report

PR · merge method, when it was not rebase and merge · issues closed by keyword, by hand, or left open for a partial ship · servers stopped · worktree removed · branches deleted · trunk head · migrations applied · ticket worktrees left open.
