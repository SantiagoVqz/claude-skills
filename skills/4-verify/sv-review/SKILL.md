---
name: sv-review
description: "Review a whole spec branch before it ships: story coverage, drift between tickets, and one browser walk of the stories."
disable-model-invocation: true
argument-hint: "<spec> [--no-ui]"
---

# Review

`/sv-review` checks what only the whole spec shows. Each ticket already passed `sv-verify` and the user's approval, so `/sv-review` does not check a ticket's acceptance criteria again. It ends with the user's approval and one review comment on the spec issue. `/sv-ship` needs that comment. `/sv-review` fixes nothing. Each gap becomes a ticket or goes out of scope.

After `EnterWorktree`, run one plain shell command per call, from the worktree root, on paths in the worktree. For a subfolder, use a flag such as `pnpm --dir` or `uv --directory`, because a `cd` stays in effect for the rest of the session. Change a file with the Edit tool, and make a new file with the Write tool. Quote each argument that holds `*`, `[` or `]`. The guard refuses only some other forms, such as a `&&` chain, `$(...)` or a heredoc, so a command that ran is no proof that its form is safe.

## 1. Load

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/sv-setup-skills`, and stop. Read the spec issue with its numbered user stories, and each of its tickets.

When a ticket is open, ask with the question tool: "Review closed only" or "Stop". On Review closed only, the review is **partial**: it covers only the stories in the `Covers stories` lines of the closed tickets.

Find the latest comment on the spec issue that starts with `### Review of #<spec>`. After step 2, compare its hash with `git rev-parse HEAD`. When they match, the review is current: tell the user that the next step is `/sv-ship <spec>`, and stop.

Completion: you have the stories in scope, and you know whether the review is partial.

## 2. Enter the spec worktree

Call `EnterWorktree` with the path of the worktree that has `spec/<spec>-<slug>`. When the current directory is already that worktree, skip the call. When no worktree has it, call the Skill tool with `sv-worktree` for that branch. Run `git pull --ff-only`. Find the trunk as the `sv-worktree` skill does.

Completion: the session is in the spec worktree, and the branch matches origin.

## 3. Run the checks

Run the full suite, the typecheck, the lint and the build, one at a time. When the repo has no script for a check, skip that check and name it on the card.

A failure in the code of the branch is a hard finding. Show its output, and stop. A failure that comes from the test environment, such as rows left in the test database or an env var from `.env`, may be fixed in the test environment only. Then run the whole check again, and put the cause, the failed test and the rerun on the card.

Completion: every check passes in one full run, and each environment fix is recorded for the card.

## 4. Coverage

For each story in scope, find the closed tickets that name it in `Covers stories`, and the tests that prove it. A story with no code or no test is a hard finding. Record each hard finding as a gap for step 7.

Read the close comment of each closed ticket. Each judgment call that it lists as open is a gap for step 7.

Completion: each story in scope has its tickets and its tests, or a gap, and each open judgment call from the tickets is a gap.

## 5. Diff review

Start a subagent with a fresh context. Give it the spec issue, the diff `<trunk>...<spec-branch>`, and this task: find **drift**, the faults that come from many tickets on one branch.

- The same logic in two tickets.
- Two names for one term of the glossary.
- A helper that one ticket added and another ticket did not use.
- A written rule of `AGENTS.md`, `CLAUDE.md` or the ADRs that the files break together, but no single ticket breaks.
- Behavior that no story asked for.
- The smells in [SMELLS.md](../sv-verify/SMELLS.md), the file in the folder of the `sv-verify` skill, across ticket lines.

The subagent edits nothing. It reports one line for each finding: `<file>:<line> · <drift> · <fix in a few words>`.

Completion: the subagent returned its findings. Each one is a gap for step 7.

## 6. Walk

Skip this step with `--no-ui`, or when no story in scope has a screen.

Call the Skill tool with `sv-ui-check`. Give it the stories in scope as the flow, one step for each story. It leaves the dev server and the tab open. A failed step is a gap for step 7.

Completion: the Verified list is in the chat, with one ✓ or ✗ line for each story in scope, or the step was skipped.

## 7. Gaps

Show each gap on one line. Ask with the question tool for each gap: "Ticket" or "Out of scope".

- A missing story gets its own ticket.
- All other gaps marked Ticket share one follow-up ticket.

Write each ticket with [TICKETS.md](../sv-prd/TICKETS.md), the file in the folder of the `sv-prd` skill, with `--parent <spec>` and one approach label from the table in `sv-plan`. Create it as `tracker.md` says.

When you created a ticket, the spec is not done. Stop the dev server, and close the tab as `sv-ui-check` says. Post the out-of-scope gaps as a comment on the spec issue, and stop. The report names the next step: `/sv-build <n>` for each new ticket, then `/sv-review` again.

Completion: each gap is in a ticket or out of scope.

## 8. Card

Write the card in your message, before the question. The question tool does not show it, and the user approves what they can read.

```markdown
### Review of #<spec> · <short commit> · full | partial

Checks: <each check from step 3> passed
Environment fixes: <cause> · <failed test> · <rerun result>

Stories: <covered> of <in scope> covered
- <n>. <story> · out of scope

Verified:
- ✓ <story step> · <what you saw>

Out of scope:
- <gap>

Open tickets: #<n>, #<n>

Check yourself at <URL>:
1. <what to do> · <what the user sees>
```

List under "Stories" only the stories that went out of scope in step 7. Leave out "Environment fixes" when step 3 had none, "Verified" and the URL when step 6 was skipped, and "Open tickets" for a full review. Keep "Check yourself" to three steps or fewer. The card has only these parts. Any other note is a gap: go to step 7.

Ask with the question tool: "Approve" or "Change". On Change, each note from the user is a gap: go to step 7. When Change comes with no notes, ask in the chat what to change. A free-text answer that clearly approves counts as Approve. Only for a free-text answer, start the reply with: "Taking that as Approve." When the question returns no answer, ask it again before any other action.

Completion: the card is in the chat above the question, and the user approved.

## 9. Post

Post the card as a comment on the spec issue, as `tracker.md` says. Under the card, add the full story list from step 4 in a `<details>` block, one line each: `<n>. <story> · #<ticket> · <test name>`. `/sv-ship` takes it as the PR evidence. The comment's first line starts with `### Review of #<spec>`, and it has the full commit hash of the spec branch head. `/sv-ship` finds the comment by this line, and stops when the head moved after it. Stop the dev server, and close the tab as `sv-ui-check` says.

Completion: the comment is on the spec issue, and no dev server from this review runs.

## Excuses

| Excuse | Answer |
|---|---|
| "The failure predates the spec." | Name the cause, the failed test and the rerun on the card. |

Add a row only when `/sv-retro` finds a new excuse.

## Report

Review comment URL · full or partial · gaps out of scope · tickets created · next step: `/sv-ship <spec>`, or `/sv-build <n>` for each new ticket.
