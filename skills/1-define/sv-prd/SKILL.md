---
name: sv-prd
description: "Write a PRD, and tickets if you want them, in any repo. No setup needed."
disable-model-invocation: true
argument-hint: "[idea | issue]"
---

# PRD

`/sv-prd` turns an idea into a PRD that a team can read, and optionally into tickets. It works in any repo, with or without `/sv-setup-skills`. It leaves the repo as it found it, except for the issues it creates or the scratch file.

## 1. Explore

Read the idea from the argument, or from the issue that it names. Then read the area of the code that the idea touches. Read `GLOSSARY.md`, the ADRs for that area, and `AGENTS.md` or `CLAUDE.md` when the repo has them. Use the words that the repo already uses. When the repo has none of these files, work from the code alone.

Completion: you can describe in a few lines how the area works today.

## 2. Interview

Call the Skill tool with `sv-interview`. The design tree for a PRD always contains these decisions, so the interview is not done until each one is settled:

- The problem, and the user who has it.
- The user stories.
- What is out of scope.
- The test seams. Propose the highest existing seam, and get the user's agreement.
- The schema changes: each migration, or none.

When a question can be answered only by seeing or running something, such as how a screen looks or how a state model behaves, offer the `sv-prototype` skill. Record its verdict in the decisions log.

The log can hold terms and ADR candidates. Use the settled terms in the PRD. The glossary and ADR files stay as they are.

Completion: the user confirmed the decisions log with an explicit yes.

## 3. Draft

Write the PRD from the decisions log with [SPEC-TEMPLATE.md](SPEC-TEMPLATE.md). Show the draft to the user, and change it until they approve it.

Completion: the user approved the draft.

## 4. Output

Ask the user where the PRD goes. Use the question tool. Offer these options:

- **GitHub issue**: offer it only when `gh repo view --json viewerPermission` shows `WRITE`, `MAINTAIN` or `ADMIN`. Create the issue with `gh issue create --title "..." --body-file <file>`. Run `gh label list` first. Add a label only when a fitting label already exists.
- **Markdown**: for Linear, Jira or a doc, where the user pastes it. In a git repo, write the PRD to `.scratch/prd/<slug>.md`, and add `.scratch/` to `.git/info/exclude` when git does not already ignore it. Outside a git repo, print the PRD in the chat.

Completion: the PRD is in the place the user chose, and you have its issue number, its file path, or the chat message.

## 5. Tickets

Ask the user whether to cut the PRD into tickets. When the answer is no, go to step 6.

1. Cut the PRD into tickets with [TICKETS.md](TICKETS.md).
2. Show the breakdown as a numbered list. For each ticket, give the title, the tickets that block it, and what it delivers.
3. Ask whether the size is right, whether each blocking edge is real, and whether to merge or split a ticket. Change the breakdown until the user approves it.
4. Publish the tickets in the same place as the PRD, blockers first:
   - **GitHub issue**: create each ticket with `gh issue create --title "..." --body-file <file> --parent <prd>`. Then add each blocking edge with `gh issue edit <ticket> --add-blocked-by <n>,<n>`. Use only labels that already exist.
   - **Markdown**: add a `## Tickets` section to the end of the PRD output. Write each ticket as a numbered item with its title, its blockers by number, what to build, and its acceptance criteria.

Completion: every approved ticket is published with its blocking edges, or the user said no to tickets.

## 6. Clean up

Delete the decisions log file, `.scratch/interview/<slug>.md`, when it exists. The published PRD is now the record.

Completion: the decisions log file is gone, or the log was kept in the conversation.

## Report

Where the PRD went: the issue URL, the file path, or the chat · the tickets created, with their numbers · the next step: the tickets that have no blockers, which the user can start now.
