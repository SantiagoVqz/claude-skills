---
name: sv-build
description: "Build one ticket in its own worktree, verify it, get the user's approval, and land it on the spec branch."
disable-model-invocation: true
argument-hint: "<ticket> [--ui]"
---

# Build

`/sv-build` takes one ticket from open to closed. It ends with the ticket as one commit on the spec branch, the spec branch pushed, the ticket closed, and the ticket worktree gone. The user approves the ticket before it lands. With `--ui`, the `sv-ui-check` skill checks it in a browser first.

After `EnterWorktree`, run one plain shell command per call from the worktree root, with no `cd`, no `-C`, no `&&` chain and no path outside the worktree. Write files with the Write tool.

## 1. Start

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/sv-setup-skills`, and stop. Read the ticket and its parent spec issue.

- **Blocked**: an issue in `blockedBy` is open. Stop, and name it.
- **Assigned to someone else**: ask with the question tool: "Take over" or "Stop". On Take over, assign the ticket to the user.
- **Approach skill missing**: the approach skill is `sv-` plus the value of the `approach:` label, so `approach:tdd` runs `sv-tdd`. When it is not installed, stop, and name it.

Set the ticket to in progress, as `tracker.md` says.

Completion: the ticket is in progress, assigned to the user, and has no open blocker.

## 2. Find the spec branch

The spec branch is `spec/<spec>-<slug>`. Find it in `git branch --list` and in `git ls-remote --heads origin`.

- **Only local**: push it with `git push -u origin <spec-branch>`.
- **Only on the remote**: the `sv-worktree` skill uses `origin/<spec-branch>`.
- **Nowhere, and a merged PR came from a `spec/<spec>-` branch**: the spec shipped in part. Make a new spec branch from the trunk with the `sv-worktree` skill.
- **Nowhere, and no merged PR**: stop. Tell the user to push the spec branch from the machine that ran `/sv-spec`.

Completion: the spec branch exists on the remote.

## 3. Make the worktree

Call the Skill tool with `sv-worktree` for `ticket/<n>-<slug>`, made from the spec branch.

When the worktree already has commits, this is a resume. Run `git status`. When a rebase is in progress, go to step 6. When `git merge-base --is-ancestor <spec-branch> HEAD` fails, rebase as in step 6 first, because a partial ship can leave the ticket on an old spec branch. Then read `git log <spec-branch>..HEAD` and run the tests. Continue from the first acceptance criterion that no commit covers.

Completion: the session is in the ticket worktree, and you know which criteria are done.

## 4. Build

Call the Skill tool with the approach skill from step 1. Give it the ticket number.

Completion: you showed the approach skill's report, and it names a test for each acceptance criterion.

## 5. Verify

Start a subagent with a fresh context. Tell it to call the Skill tool with `sv-verify`, with the ticket number and the diff `<spec-branch>...HEAD`.

Fix only the hard findings before the checkpoint. Each judgment call goes on the card, also one that you caused. Fix each hard finding, commit, and run `sv-verify` in a new subagent one more time. When a hard finding is still there, stop. Show the findings. The ticket stays in progress and the worktree stays. The user fixes it, or overrides it with a reason. Keep the reason for the commit message in step 8.

Completion: the last `sv-verify` run has no hard finding, or the user gave an override reason.

## 6. Rebase

Run `git rebase <spec-branch>`. On a conflict, call the Skill tool with `sv-resolve-conflicts`. Then run the full suite, the typecheck and the build.

When you resolved a conflict, run `sv-verify` in a new subagent, as in step 5. The code changed, so an earlier approval and an earlier `sv-ui-check` run no longer count. A clean rebase keeps both.

Completion: the ticket branch is on the latest spec branch, every check passes, and each conflict is resolved.

## 7. Checkpoint

When the user approved before a clean rebase, go to step 8.

When the user passed `--ui`, call the Skill tool with `sv-ui-check` for this ticket first. It leaves the dev server and the tab open, so the user can look while the question waits.

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

Keep "Check yourself" to three steps or fewer, on the main flow of the ticket. Start no dev server and open no browser yourself. Only `sv-ui-check` does that.

Ask with the question tool: "Approve", "Change" or "Run ui-check". Leave out "Run ui-check" when it already ran. On Run ui-check, call the Skill tool with `sv-ui-check` for this ticket, then ask again with "Approve" or "Change". On Change, make the edits, commit, run `sv-verify` in a new subagent, and go back to step 6. When Change comes with no notes, ask in the chat what to change. Offer no list of options that you picked.

A free-text answer that clearly approves, such as "looks good", counts as Approve. Start the reply with: "Taking that as Approve."

When a question in this step returns no answer, such as after an interrupt, ask it again before any other action.

Completion: the user approved. Stop the dev server and close the tab, when `sv-ui-check` started them.

## 8. Land

Call `EnterWorktree` with the path of the spec worktree. Run `git merge-base --is-ancestor <spec-branch> <ticket-branch>`. When it fails, another ticket landed first: go back to the ticket worktree and to step 6. A clean rebase lands with no new question. A resolved conflict goes to the user again.

Squash the ticket into one commit: `git merge --squash <ticket-branch>`, then `git commit -m "<ticket title> (#<n>)"`. Add `-m "Override: <reason>"` when the user gave one. Push the spec branch.

Completion: the spec branch on the remote has the ticket commit.

## 9. Close

Close the ticket as `tracker.md` says. The comment has the commit hash, and each judgment call from the card that no change fixed, under "Open judgment calls:". `/sv-review` makes each one a gap. Remove the ticket worktree with the `sv-worktree` skill.

Completion: the ticket is closed, and `git worktree list` does not show the ticket worktree.

## Report

Ticket · commit on the spec branch · override reasons · tickets that this ticket unblocked · next step: `/sv-build <n>` for each one, or `/sv-review <spec>` when the spec has no open ticket.
