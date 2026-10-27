---
name: final-review
description: "Review a built spec or lone ticket before it ships: the checks, story coverage, and a browser walk when the user asks. Fixes blocking gaps and the changes the user asks for in the same run, then posts the review comment. Use when /build ends, or the user asks to review a built spec."
argument-hint: "<spec | ticket>"
---

# Review

`final-review` checks what only the whole branch shows. `/build` calls it after the last phase, as the close of the build, and the user can run it on its own. Each phase already passed `verify`, so the review does not check a phase's criteria again. It ends with the user's approval and one review comment on the issue. `/ship` needs that comment.

The review **fixes** each blocking gap, and each change the user asks for at the card, in the same run, so neither needs another `/build`. The card is where the user iterates, such as on a design. The fix runs in subagents, as `/build` runs a phase, so this context stays small.

After `EnterWorktree`, run one plain shell command per call, from the worktree root, on paths in the worktree. Use the **shell rules** of the `build` skill, and paste them into each subagent prompt.

## 1. Load

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/setup-skills`, and stop. Read the issue with its comments.

The **stories in scope** are the numbered user stories of a spec, or the acceptance criteria of a lone ticket, which then count as its stories. Read the plan: the latest comment `### Plan of #<n>` of a spec, or the one phase of a lone ticket.

Completion: you have the stories in scope and the phases of the plan.

## 2. Enter the worktree

Call `EnterWorktree` with the path of the worktree that has the branch, `spec/<n>-<slug>` or `fix/<n>-<slug>`. When the current directory is already that worktree, skip the call. When no worktree has it, call the Skill tool with `worktree` for that branch. When the branch tracks a remote, run `git pull --ff-only`. Find the trunk as the `worktree` skill does.

Read `git log --format='%h %s%n%b' origin/<trunk>..HEAD`. Each phase commit has a `Phase:` trailer, a `<criterion> · <test name>` line for each criterion, and its open judgment calls.

- **A phase has no commit**: stop. The next step is `/build <n>`, which resumes.
- **The latest comment that starts with `### Review of #<n>` has the hash of `git rev-parse HEAD`**: the review is current. Stop. The next step is `/ship <n>`.

Send one line to the user: the count of phases and of stories in scope.

Completion: the session is in the worktree, each phase has its commit, and the user has the one line.

## 3. Gaps

Each gap of this review is one of two kinds. Sort each gap as you record it:

- **Blocking**: a failed check, a story with no code or no test, a failed walk step, a change the user asks for at the card, or a defect that a user can see or that stores or sends wrong data, such as a false text, a lost value or a stale screen. The review fixes it in step 6.
- **Cleanup**: every other finding, such as duplication, a smell, a name, a comment or a missing test of a case that works. The card lists it with Skip or Later.

Completion: you can sort each finding of steps 4 and 5, and of the walk.

## 4. Run the checks

Start a subagent with a fresh context. Tell it to run the full suite, the typecheck, the lint and the build, one at a time, and to return pass or fail for each, with the output of each failure only. When the repo has no script for a check, it skips the check and names it.

A failure in the code of the branch is a blocking gap. A failure that comes from the test environment, such as rows left in the test database or an env var from `.env`, may be fixed in the test environment only. Then the subagent runs the whole check again. Put the cause, the failed test and the rerun on the card. When no open issue names the cause, call the Skill tool with `issue` to file it once, and put its number on the card.

Completion: each check passed or is a blocking gap, and each environment fix is recorded for the card, with its issue.

## 5. Coverage

For each story in scope, find the phase that covers it in the plan, and the tests in that phase's commit lines. A story with no code or no test is a blocking gap.

Each open judgment call in a phase commit is a gap. Sort it as blocking or cleanup.

Completion: each story in scope has its phase and its tests, or a blocking gap, and each open judgment call is a sorted gap.

## 6. Fix

Skip this step when no gap is blocking.

Write the blocking gaps in your message, one line each. Then fix them with no question, as `/build` builds a phase:

1. Record the fix start: `git rev-parse HEAD`.
2. Start an implementer subagent with a fresh context. Give it the worktree path, the shell rules, the issue number, the fix start and the gaps word for word. Its task: call the Skill tool with `tdd`, with each gap as a criterion, so each fix has a test that failed first. A change that no test can observe, such as a spacing or a color, goes to `tdd` as a `Build:` piece. A question from it goes to the user as in `/build`.
3. Run `verify` in a new subagent on `<fix start>...HEAD`, and send its hard findings back to the implementer, three verify runs or fewer, as `/build` does.
4. Squash the fix into one commit, `Fix review gaps (#<n>)`, with one line for each gap: `<gap> · <test name>`. Push it when the branch tracks a remote.
5. Run again the step that found each gap: the checks, the coverage or the walk step.

Run two fix rounds or fewer for the gaps that the review found. A change that the user asks for at the card gets its own round each time. When a gap that the review found remains after the second round, stop. Show the gaps. The user fixes them, or moves each one out of scope with a reason.

Completion: no gap is blocking, or the user moved each remaining one out of scope.

## 7. Card

Give each cleanup an action. **Skip** is the default: the card lists it. **Later** puts it in one lone ticket that ships on its own. Recommend Later only for a cleanup that costs the code more each time someone touches it.

Write the card in your message, before the question. The question tool does not show it, and the user approves what they can read.

```markdown
### Review of #<n> · <short commit>

Phases: <k> · <short hash of each>
Checks: <each check from step 4> passed
Environment fixes: <cause> · <failed test> · <rerun result> · #<issue>

Stories: <covered> of <in scope> covered
- <n>. <story> · out of scope · <reason>

Fixed in review:
- <gap> · <test name>

Verified:
- ✓ <story step> · <what you saw>

Cleanup:
- <gap> · skip | later

Check yourself at <URL, or with `<run command>` before the walk>:
1. <what to do> · <what the user sees>
```

List under "Stories" only the stories that went out of scope. Leave out "Environment fixes" when step 4 had none, "Fixed in review" when step 6 was skipped, "Verified" until the walk ran, and "Cleanup" when it is empty. Keep "Check yourself" to three steps or fewer. The card has only these parts.

Ask with the question tool: "Approve", "Change" or "Walk in browser". Offer "Walk in browser" only when a story in scope has a screen and no walk ran on this commit.

- **Walk in browser**: call the Skill tool with `ui-check`. Give it the stories in scope as the flow, one step for each story. It leaves the dev server and the tab open, so the user can look while the question waits. A failed step is a blocking gap: go to step 6. Then show the card again with its Verified lines, and ask again.
- **Change**: each note from the user is a change to make, such as a design tweak, or a new action for a cleanup. A change goes to step 6. Then show the card again and ask again. When Change comes with no notes, ask in the chat what to change.

A free-text answer that clearly approves counts as Approve. Only for a free-text answer, start the reply with: "Taking that as Approve." When the question returns no answer, ask it again before any other action.

Completion: the card is in the chat above the question, and the user approved.

## 8. Post

When a cleanup is marked Later, call the Skill tool with `issue` to file all of them as one lone ticket, written with the `Lone ticket` section of [TICKETS.md](../../1-define/prd/TICKETS.md), with one approach from the table in [PLAN.md](../../2-build/build/PLAN.md).

Post the card as a comment on the issue, as `tracker.md` says. Its first line is `### Review of #<n> · <full commit hash of HEAD>`. `/ship` finds the comment by this line, and stops when the head moved after it. Put "Cleanup later: #<n>" under the card when you filed the ticket. Under the card, add the full story list in a `<details>` block, one line each: `<n>. <story> · phase <k> · <test name>`. `/ship` takes it as the PR evidence.

When the walk ran, stop the dev server, and close the tab as `ui-check` says.

Completion: the comment is on the issue, and no dev server from this review runs.

## Excuses

| Excuse | Answer |
|---|---|
| "The failure predates the spec." | Name the cause, the failed test and the rerun on the card. |
| "The finding is real, so it is blocking." | A real cleanup is still a cleanup. Only a blocking gap gets a fix round. |

Add a row only when `/retro` finds a new excuse.

## Report

Review comment URL · gaps fixed in review · stories out of scope · cleanup ticket · next step: `/ship <n>`.
