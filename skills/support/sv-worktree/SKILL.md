---
name: sv-worktree
description: "Make, provision or remove the linked worktree for a spec, ticket or fix branch, with its databases. Use before code work starts on a branch, before you add a migration, and to tear a worktree down after its merge."
---

# Worktree

Code work runs in a linked worktree. The primary checkout stays on the trunk. This skill reads git facts only, so a worktree made by this skill, by `git worktree add` or by another tool resolves the same way.

## Branches

| Branch | Made from | Dev database |
|---|---|---|
| `spec/<n>-<slug>` | the trunk | its own fork |
| `ticket/<n>-<slug>` | its spec branch | the fork of its spec |
| `fix/<n>-<slug>` | the trunk | its own fork |

A `fix/` branch is for each issue that ships alone: a bug, or a ticket whose spec has no branch.

Each worktree also has its own test database. `scripts/provision.sh` applies these rules.

The **trunk** is the branch that PRs merge into: the default branch from `git symbolic-ref refs/remotes/origin/HEAD`, or `develop` when the repo has both `main` and `develop`. When `origin/HEAD` is missing, use `gh repo view --json defaultBranchRef`. Do not run `git remote set-head`, because it changes the repo config.

## Make

1. **Locate.** Read `git worktree list --porcelain`. When you know only the issue number, match any `<type>/<n>-` branch in it and in `git branch -a` before you make a new one. Take the case that matches:
   - A worktree has the branch: use its path, and go on to steps 2 to 4.
   - No worktree has it: `git fetch origin`, then `git worktree add -b <branch> .claude/worktrees/<branch with / as -> <base>`. Use `origin/<trunk>` as the base for a spec or fix branch, and the local spec branch for a ticket. Leave out `-b` when the branch exists.
   - The primary checkout has the branch: stop and say so. A branch is checked out in one place only.
2. **Link a ticket to its spec.** For a ticket branch, run `git config branch.<ticket-branch>.spec <spec-branch>` before you provision. This line is how `provision.sh` finds the spec's database.
3. **Enter.** `EnterWorktree` on the worktree path. Only `EnterWorktree` puts the guard on the session, so never enter with `cd`. After this, the harness refuses commands that it cannot prove stay in the worktree. This covers every shell command, not only git. Run one plain command per call from the worktree root: no `cd`, no `-C`, no `&&` chain, no `$(...)`, no shell variable and no path outside the worktree. A `cd` stays in effect for the rest of the session. For a subfolder, use a flag such as `pnpm --dir` or `uv --directory`. Write files with the Write tool, not a heredoc. Pass a commit message with one `-m` flag per paragraph. A message file in the worktree can get committed.
4. **Provision.** When `scripts/provision.sh` exists, run it in the worktree. When it fails, show the end of its output and stop. When it does not exist and the repo has gitignored `.env` files, a lockfile or a database URL, the worktree is not ready. Copy no `.env` file by hand. Tell the user to run `/sv-setup-skills`, and stop.

Completion: the session is in the worktree, and the end of the `provision.sh` output names the expected dev and test databases, or the repo needs no provisioning. Otherwise the report says `blocked: run /sv-setup-skills`.

## Remove

Run this from the primary checkout after the branch is merged, into the spec branch for a ticket, or into the trunk for a spec or fix.

1. Call `EnterWorktree` with the worktree path, and skip the call when the session is already there. Run `scripts/provision.sh drop`. The script drops the test database, and the dev fork when the branch owns one. A ticket leaves its spec's fork alone. Then call `ExitWorktree` with `keep` to go back to the primary checkout.
2. `git worktree remove <path>`. When it refuses because of uncommitted or untracked files, stop and show them. Keep the files: no `--force`.
3. `git branch -D <branch>`. It also removes the `branch.<branch>` config, with the spec link of a ticket.

Completion: `git worktree list` does not show the path, and the branch is gone.

## Migrations

Only the branch that owns the dev database migrates it, or the schema ticket of a spec. When a different ticket needs a migration, stop and report it to the user. The plan missed a schema change, and a second migration on a shared fork breaks the parallel tickets.

## Excuses

| Excuse | Answer |
|---|---|
| "The ticket is frontend only, so I can copy the `.env` files." | A copied `.env` points at the shared dev database, and a browser check later needs the API and the database. Stop, and tell the user to run `/sv-setup-skills`. |

Add a row only when `/sv-retro` finds a new excuse.

## Report

`<path> · <branch> · made | found | removed · dev <db> · test <db>`
