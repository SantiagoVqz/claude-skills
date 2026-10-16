---
name: build
description: "Build one ticket in its own worktree, verify it, walk the user through it, and land it on the spec branch."
disable-model-invocation: true
argument-hint: "<ticket> [--ui]"
---

# Build

`/build` takes one ticket from open to closed. It ends with the ticket as one commit on the spec branch, the spec branch pushed, the ticket closed, and the ticket worktree gone. The user approves the ticket before it lands. With `--ui`, the `ui-check` skill checks it in a browser first.

After `EnterWorktree`, run one plain shell command per call from the worktree root, with no `cd`, no `-C`, no `&&` chain and no path outside the worktree. Write files with the Write tool.

## 1. Start

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/setup-skills`, and stop. Read the ticket and its parent spec issue.

- **Blocked**: an issue in `blockedBy` is open. Stop, and name it.
- **Assigned to someone else**: ask with the question tool: "Take over" or "Stop". On Take over, assign the ticket to the user.
- **Approach skill missing**: the skill that the `approach:` label names is not installed. Stop, and name it.

Set the ticket to in progress, as `tracker.md` says.

Completion: the ticket is in progress, assigned to the user, and has no open blocker.

## 2. Find the spec branch

The spec branch is `spec/<spec>-<slug>`. Find it in `git branch --list` and in `git ls-remote --heads origin`.

- **Only local**: push it with `git push -u origin <spec-branch>`.
- **Only on the remote**: the `worktree` skill uses `origin/<spec-branch>`.
- **Nowhere, and a merged PR came from a `spec/<spec>-` branch**: the spec shipped in part. Make a new spec branch from the trunk with the `worktree` skill.
- **Nowhere, and no merged PR**: stop. Tell the user to push the spec branch from the machine that ran `/spec`.

Completion: the spec branch exists on the remote.

## 3. Make the worktree

Call the Skill tool with `worktree` for `ticket/<n>-<slug>`, made from the spec branch.

When the worktree already has commits, this is a resume. Read `git log <spec-branch>..HEAD` and run the tests. Continue from the first acceptance criterion that no commit covers.

Completion: the session is in the ticket worktree, and you know which criteria are done.

## 4. Build

Call the Skill tool with the skill that the `approach:` label names. Give it the ticket number.

Completion: you showed the approach skill's report, and it names a test for each acceptance criterion.

## 5. Verify

Start a subagent with a fresh context. Tell it to call the Skill tool with `verify`, with the ticket number and the diff `<spec-branch>...HEAD`.

Fix each hard finding, commit, and run `verify` in a new subagent one more time. When a hard finding is still there, stop. Show the findings. The ticket stays in progress and the worktree stays. The user fixes it, or overrides it with a reason. Keep the reason for the commit message in step 8.

Completion: the last `verify` run has no hard finding, or the user gave an override reason.

## 6. Rebase

Run `git rebase <spec-branch>`. On a conflict, stop and show it. Then run the full suite, the typecheck and the build.

Completion: the ticket branch is on the latest spec branch, and every check passes.

## 7. Checkpoint

When the user passed `--ui`, call the Skill tool with `ui-check` for this ticket first.

Then show one card:

```markdown
### #<n> <title>
- <criterion> · <test name>
- ...

Judgment calls:
- <one line each, from verify>

Check yourself: `<run command>`
1. <a step and what the user sees>
```

Keep "Check yourself" to three steps or fewer, on the main flow of the ticket. Start no dev server and open no browser, unless `--ui` is set.

Ask with the question tool: "Approve", "Change" or "Run ui-check". Leave out "Run ui-check" when it already ran. On Run ui-check, call the Skill tool with `ui-check` for this ticket, then ask again with "Approve" or "Change". On Change, make the edits, commit, run `verify` in a new subagent, and go back to step 6.

Completion: the user picked Approve.

## 8. Land

Call `EnterWorktree` with the path of the spec worktree. Run `git merge-base --is-ancestor <spec-branch> <ticket-branch>`. When it fails, another ticket landed first: go back to the ticket worktree and to step 6.

Squash the ticket into one commit: `git merge --squash <ticket-branch>`, then `git commit -m "<ticket title> (#<n>)"`. Add `-m "Override: <reason>"` when the user gave one. Push the spec branch.

Completion: the spec branch on the remote has the ticket commit.

## 9. Close

Close the ticket as `tracker.md` says, with the commit hash in the comment. Remove the ticket worktree with the `worktree` skill.

Completion: the ticket is closed, and `git worktree list` does not show the ticket worktree.

## Report

Ticket · commit on the spec branch · override reasons · tickets that this ticket unblocked · next step: `/build <n>` for each one, or `/review <spec>` when the spec has no open ticket.
