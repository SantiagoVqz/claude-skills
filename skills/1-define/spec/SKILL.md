---
name: spec
description: "Turn an idea into a spec with an interview, and cut it into tickets that each build in one session. Works in any repo."
disable-model-invocation: true
argument-hint: "[idea | issue]"
---

# Spec

`/spec` is the start of a feature. It ends with a spec that a team can read, cut into tickets that `/build` takes one at a time. It makes no branch, no worktree and no commit.

## 1. Load

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md` and `docs/agents/domain.md`. When the block is missing, read `NO-SETUP.md` in the folder of the `setup-skills` skill, and go on with its sources.

Read the idea from the argument, or from the issue that it names. Then read the area of the code that the idea touches, the glossary and the ADRs for that area.

Completion: you can describe in a few lines how the area works today.

## 2. Interview

Call the Skill tool with `interview`. The design tree for a spec always contains these decisions:

- The problem, and the user who has it.
- What each user can do and check. You write the user stories from these answers.
- What is out of scope.
- The test seams. Propose the highest existing seam.
- The schema changes: each migration, or none.
- The look of each new or changed screen, when the spec touches a screen: "prototype it, or keep it plain?" On prototype, call the Skill tool with `prototype`, and record the chosen variant with its link.

During the interview, say at once when a word conflicts with the glossary, propose one exact term for a vague word, and show each place where the user's account differs from the code.

Completion: the interview returned the decisions log, with each decision above settled.

## 3. Draft

Write the spec from the log with [SPEC-TEMPLATE.md](SPEC-TEMPLATE.md). Its `Domain changes` section takes the terms and ADR candidates of the log, and nothing else.

Cut the spec into tickets with [TICKETS.md](TICKETS.md). Estimate the lines for each story, with its tests and fixtures, then multiply the sum by 1.5, because a 1900 line estimate shipped 3024 lines.

This is the one approval. Write this list in your message, before the question, because the question tool does not show it:

```markdown
You approve:
- Problem: <who has it, and what it costs them>
- Scope: <what the feature does>
- Out of scope: <each item>
- Seams: <each seam>
- Schema: <each migration, or none>
- Look: <the chosen variant with its link, or plain>
- Domain: <each new term and ADR, or none>
- Size: about <lines> changed lines
- Tickets:
  1. <title> · <what it delivers> · blocked by: <refs, or none>
```

Ask with the question tool: "Approve" or "Change". On Change, apply the edits, show the list again and ask again. A term or a decision that is not in the log goes to the user before you publish.

Completion: the list is in the chat above the question, and the user approved.

## 4. Publish

With a tracker, call the Skill tool with `issue`, with one list: the spec with the `spec` label, then each ticket with the spec as its parent, and its blockers by ref.

With no tracker, write the spec and its `## Tickets` section to `.scratch/spec/<slug>.md`, and add `.scratch/` to `.git/info/exclude` when git does not already ignore it. Outside a git repo, print them in the chat.

Then delete the decisions log file. The spec is now the record.

Completion: the spec and each ticket exist, and the log file is gone.

## Report

Spec URL or file path · each ticket with its number and blockers · next step: `/build <n>` for each ticket with no blocker.
