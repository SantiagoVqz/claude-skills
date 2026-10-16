---
name: plan
description: "Cut a spec issue into tickets: sub-issues with approach labels and blocking links."
disable-model-invocation: true
argument-hint: "<spec issue>"
---

# Plan

`/plan` turns a spec issue into tickets that `/build` can start. It ends with each user story covered by a ticket, each ticket labeled with its approach, and each blocking edge linked in the tracker. It changes no code and no branch.

## 1. Load the setup

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/setup-skills`, and stop. Run `gh label list`. When a label from the table in `tracker.md` is missing, tell the user to run `/setup-skills`, and stop.

Completion: you know how to create, label and link an issue in this repo, and each label exists.

## 2. Read the spec

Read the spec issue with its sub-issues. When it does not have the `spec` label, stop and say so.

Then read the domain docs and the code in the area that the spec touches. The glossary and ADRs of the spec exist only on the spec branch until it merges:

- A worktree has the spec branch: read the files there.
- No worktree has it: read each file with `git show spec/<n>-<slug>:<path>`.
- No spec branch exists: read the files on the trunk.

Sort the existing tickets:

- A **closed** ticket covers its stories.
- An **open** ticket stays as it is. You do not edit it, relabel it or close it. When you think it is wrong, record why for the report.

Completion: you have the spec's numbered user stories, and the stories that no ticket covers.

## 3. Cut

Cut the uncovered stories into tickets with [TICKETS.md](../prd/TICKETS.md), the file in the folder of the `prd` skill. A new ticket can be blocked by an existing ticket.

Give each ticket one approach label. `/build` runs the skill that the label names:

| Label | When |
|---|---|
| `approach:tdd` | The ticket adds or changes behavior. |
| `approach:refactor` | The behavior stays the same: a prefactor, or a batch of a wide refactor. |
| `approach:diagnose` | The ticket starts from a defect whose cause is unknown. |

Check coverage: each uncovered story is in the `Covers stories` line of one new ticket or more. When a story is in no ticket, cut a ticket for it, or ask the user whether it is out of scope.

Completion: each uncovered story is in a ticket, and each ticket has one approach label.

## 4. Approve

Write the breakdown in your message, before the question, as one card for each ticket. A one-sentence summary is not the breakdown: the user approves what they can read.

```markdown
### 1. <title>
<approach> · stories 1, 2 · blocked by: none

Builds: <one sentence, from the user's point of view>
Done when:
- <each acceptance criterion>

### 2. <title>
...

Order: <which tickets start at once, and which run in parallel after them>
```

After the cards, show the existing open tickets that you think are wrong, with the reason.

Then ask for approval with the question tool. Give the options "Approve" and "Change". When the user picks Change, apply the edits, show the list again and ask again.

Completion: the user picked Approve.

## 5. Publish

Create the tickets in order, blockers first, so that each blocker has a number before the ticket that it blocks. Use the template in `TICKETS.md`, the `--parent <spec>` flag and the approach label. Then add each blocking edge.

Completion: each approved ticket is a sub-issue of the spec, with its label and its blocking edges.

## Report

Tickets created, with numbers and labels · existing open tickets that you think are wrong, with the reason · next step: `/build <n>` for each ticket that has no open blocker.
