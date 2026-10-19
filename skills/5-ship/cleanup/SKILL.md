---
name: cleanup
description: "Tear down a merged spec or fix branch: check the merged PR, close the issues, remove the worktree and branches, and refresh the trunk."
disable-model-invocation: true
argument-hint: "[spec | bug]"
---

# Cleanup

`/cleanup` runs after the user merges a PR from `/ship`. It ends with the issues in the right state, the worktree and branches gone, and the primary checkout on the latest trunk. It deletes nothing before the gate passes.

Run it from the primary checkout. When the session is in a worktree, call `ExitWorktree` with `keep` first.

## 1. Find

The target is the argument, or the branch you just shipped: `spec/<n>-<slug>` or `fix/<n>-<slug>`. Find the trunk as the `worktree` skill does.

Completion: you have the branch, its issue and the trunk.

## 2. Gate

Run `gh pr list --head <branch> --state all --json number,url,state,body`.

- **A merged PR**: go on. A rebase merge and a squash merge both show as merged.
- **An open PR**: stop, and give its URL.
- **No PR**: stop. The next step is `/ship`.

Completion: the branch has a merged PR.

## 3. Issues

Read the closing line of the PR body.

- **`Closes #<n>`**: read the issue and, for a spec, each of its tickets. Close each one that is still open, as `tracker.md` says: the tickets first, then the spec. The keyword fires only on a merge into the default branch, so when the trunk is not the default branch, a close by hand is the normal path.
- **`Part of #<spec>`**: a partial ship. The spec and its open tickets stay open.

Completion: each issue is in the state that the closing line gives, and you know which closed by keyword and which by hand.

## 4. Worktree

Call the Skill tool with `worktree` to remove the worktree of the branch. Ticket worktrees of the spec stay. The next `/build` on such a ticket makes a new spec branch and rebases the ticket onto it.

Completion: `git worktree list` does not show the branch, and the local branch is gone.

## 5. Remote branch

Run `git ls-remote --exit-code --heads origin <branch>`. When the branch is there, run `git push origin --delete <branch>`. GitHub can delete it on merge, so a missing branch is normal.

Completion: origin does not have the branch.

## 6. Trunk

Record the trunk head with `git rev-parse HEAD`. Run `git pull --ff-only`. When it does not fast-forward, stop and show why. Keep the local commits: no force.

Completion: the primary checkout is on the latest trunk.

## 7. Migrations

Run `git diff --name-only <old head> HEAD`. When it shows new migrations, run the migrate command from `AGENTS.md` or `package.json` on the trunk dev database. When the repo has no such command, name the migrations in the report.

Completion: the trunk dev database has each new migration, or the report names them.

## Report

PR · issues closed by keyword, by hand, or left open for a partial ship · worktree removed · branches deleted · trunk head · migrations applied · ticket worktrees left open.
