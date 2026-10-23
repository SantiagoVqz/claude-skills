---
name: sv-review
description: "Review a whole spec branch before it ships: story coverage, drift between tickets, and one browser walk of the stories. A one-ticket spec gets a light review of coverage only."
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

Decide the review mode. The review is **light** when the spec has exactly one ticket, the ticket is closed, and `git rev-parse HEAD` matches the commit hash in its close comment. `/sv-build` already ran every check and a fresh verify on that commit, and the browser check when a criterion shows in a browser, and `/sv-ship` runs every check again. A light review skips steps 3, 5 and 6. Any other spec gets the full set of steps.

Send one line to the user: full, partial or light, and the count of tickets.

Completion: the session is in the spec worktree, the branch matches origin, you know whether the review is light, and the user has the one line.

## 3. Run the checks

Skip this step in a light review.

Run the full suite, the typecheck, the lint and the build, one at a time. When the repo has no script for a check, skip that check and name it on the card.

A failure in the code of the branch is a hard finding. Show its output, and stop. A failure that comes from the test environment, such as rows left in the test database or an env var from `.env`, may be fixed in the test environment only. Then run the whole check again, and put the cause, the failed test and the rerun on the card. When no open issue names the cause, call the Skill tool with `sv-issue` to file it once, and put its number on the card.

Print no value from an env file, because a line such as `PROD_DATABASE_URL` holds a password. To see which variables a file sets, list the names only: `grep -oE '^[A-Z_]+=' <file>`.

Completion: every check passes in one full run, and each environment fix is recorded for the card, with its issue.

## 4. Coverage

Each gap of this review is one of two kinds. Sort each gap as you record it:

- **Blocking**: a story with no code or no test, a failed walk step, or a defect that a user can see or that stores or sends wrong data, such as a false text, a lost value or a stale screen. The spec waits for it.
- **Cleanup**: every other finding, such as duplication, a smell, a name, a comment or a missing test of a case that works. The spec ships without it.

For each story in scope, find the closed tickets that name it in `Covers stories`, and the tests that prove it. A story with no code or no test is a blocking gap for step 7.

Read the close comment of each closed ticket. Each judgment call that it lists as open is a gap for step 7. Sort it as blocking or cleanup.

Completion: each story in scope has its tickets and its tests, or a blocking gap, and each open judgment call from the tickets is a sorted gap.

## 5. Diff review

Skip this step in a light review.

Find the base of the diff. When the spec issue has a comment that starts with `### Gaps of #<spec>`, take the latest one. The base is the commit in its first line, because an earlier review already read the diff up to that commit. With no such comment, the base is the trunk.

Start a subagent with a fresh context. Give it the spec issue, the diff `<base>...<spec-branch>`, the two kinds of gap from step 4, and this task: find **drift**, the faults that come from many tickets on one branch.

- The same logic in two tickets.
- Two names for one term of the glossary.
- A helper that one ticket added and another ticket did not use.
- A written rule of `AGENTS.md`, `CLAUDE.md` or the ADRs that the files break together, but no single ticket breaks.
- Behavior that no story asked for.
- The smells in [SMELLS.md](../sv-verify/SMELLS.md), the file in the folder of the `sv-verify` skill, across ticket lines.

The subagent edits nothing. It reports every blocking finding, and the five cleanups that cost the code most. One line for each: `<file>:<line> · blocking | cleanup · <drift> · <fix in a few words>`.

Completion: the subagent returned its findings. Each one is a gap for step 7, with its kind.

## 6. Walk

Skip this step in a light review, with `--no-ui`, or when no story in scope has a screen.

Call the Skill tool with `sv-ui-check`. Give it the stories in scope as the flow, one step for each story. It leaves the dev server and the tab open. A failed step is a blocking gap for step 7.

Completion: the Verified list is in the chat, with one ✓ or ✗ line for each story in scope, or the step was skipped.

## 7. Gaps

Skip this step when no gap exists.

Write every gap in your message as one list, before the question, blocking gaps first. Give each gap one line, with its kind and its action:

| Kind | Actions | Recommend |
|---|---|---|
| Blocking | **Ticket**: a sub-issue of the spec. The spec waits for it. **Out of scope**: the spec ships without it. | Ticket |
| Cleanup | **Later**: a lone ticket with no parent. The spec does not wait for it. **Skip**: the card lists it under "Cleanup skipped". | Skip |

Ask one question with the question tool: "As listed" or "Change". On Change, apply the user's edits to the actions, show the list again and ask again.

Then publish. A missing story marked Ticket gets its own ticket. All other blocking gaps marked Ticket share one follow-up ticket. Write each sub-issue with [TICKETS.md](../sv-prd/TICKETS.md), the file in the folder of the `sv-prd` skill, and one approach label from the table in `sv-plan`. All cleanups marked Later share one lone ticket, written with the `Lone ticket` section of `TICKETS.md`. Read the criteria of each ticket together before you publish it. When two criteria cannot both hold, such as "a save loads no data" and "a failed load on save keeps the typed values", settle the pair with the user, or keep one of them. Call the Skill tool with `sv-issue`, and hand it the tickets with the spec as the parent of each sub-issue.

When you created a sub-issue, the spec is not done. Stop the dev server, and close the tab as `sv-ui-check` says. Post a comment on the spec issue whose first line is `### Gaps of #<spec> · <full commit hash of HEAD>`, with the gaps out of scope and the cleanups skipped. The next review reads only the diff after that commit. Then stop. The report names the next step: `/sv-build <n>` for each new sub-issue, then `/sv-review` again.

Completion: the user approved the list, and each gap has its action.

## 8. Card

Write the card in your message, before the question. The question tool does not show it, and the user approves what they can read.

```markdown
### Review of #<spec> · <short commit> · full | partial

Checks: <each check from step 3> passed
Light: one ticket, #<n> at <short commit>. Its checks, verify and browser check ran in /sv-build.
Environment fixes: <cause> · <failed test> · <rerun result> · #<issue>

Stories: <covered> of <in scope> covered
- <n>. <story> · out of scope

Verified:
- ✓ <story step> · <what you saw>

Out of scope:
- <gap>

Cleanup skipped:
- <gap>

Cleanup later: #<n>

Open tickets: #<n>, #<n>

Check yourself at <URL>:
1. <what to do> · <what the user sees>
```

List under "Stories" only the stories that went out of scope in step 7. A light review has the "Light" line in place of "Checks". Leave out "Light" for any other review, and "Environment fixes" when step 3 had none, "Verified" and the URL when step 6 was skipped, "Out of scope", "Cleanup skipped" and "Cleanup later" when they are empty, and "Open tickets" for a full review. Keep "Check yourself" to three steps or fewer. The card has only these parts. Any other note is a gap: go to step 7.

Ask with the question tool: "Approve" or "Change". On Change, each note from the user is a gap: go to step 7. When Change comes with no notes, ask in the chat what to change. A free-text answer that clearly approves counts as Approve. Only for a free-text answer, start the reply with: "Taking that as Approve." When the question returns no answer, ask it again before any other action.

Completion: the card is in the chat above the question, and the user approved.

## 9. Post

Post the card as a comment on the spec issue, as `tracker.md` says. Under the card, add the full story list from step 4 in a `<details>` block, one line each: `<n>. <story> · #<ticket> · <test name>`. `/sv-ship` takes it as the PR evidence. The comment's first line starts with `### Review of #<spec>`, and it has the full commit hash of the spec branch head. `/sv-ship` finds the comment by this line, and stops when the head moved after it. Stop the dev server, and close the tab as `sv-ui-check` says.

Completion: the comment is on the spec issue, and no dev server from this review runs.

## Excuses

| Excuse | Answer |
|---|---|
| "The failure predates the spec." | Name the cause, the failed test and the rerun on the card. |
| "The finding is real, so the spec waits for it." | A real cleanup is still a cleanup. Only a blocking gap holds the spec. |

Add a row only when `/sv-retro` finds a new excuse.

## Report

Review comment URL · full or partial · light or not · gaps out of scope · tickets created · next step: `/sv-ship <spec>`, or `/sv-build <n>` for each new ticket.
