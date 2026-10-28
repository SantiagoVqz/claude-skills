---
name: spec
description: "Turn an idea into a spec issue through an interview, or into a project of child specs when it is too big for one PR."
disable-model-invocation: true
argument-hint: "[idea | issue]"
---

# Spec

`/spec` is the start of a feature. It ends with a spec issue that a team can read and comment on, and a user who agrees with it. An idea too big for one PR ends as a **project**: a parent issue with child specs that each ship alone. It makes no branch, no worktree and no commit: `/build` makes the branch and commits the glossary and ADR changes from the issue.

## 1. Load the setup

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md` and `docs/agents/domain.md`. When the block is missing, tell the user to run `/setup-skills`, and stop.

Completion: you know how to create and label an issue in this repo.

## 2. Explore

Read the idea from the argument, or from the issue that it names. Then read the area of the code that the idea touches, the glossary that `docs/agents/domain.md` names, and the ADRs for that area.

Completion: you can describe in a few lines how the area works today.

## 3. Interview

Call the Skill tool with `interview`. The design tree for a spec always contains these decisions, so the interview is not done until each one is settled:

- The problem, and the user who has it.
- What each user can do and check. You write the user stories from these answers in step 4.
- What is out of scope.
- The test seams. Propose the highest existing seam, and get the user's agreement.
- The schema changes: each migration, or none.
- The look of each new or changed screen, when the spec touches a screen. Ask "prototype it, or keep it plain?" On prototype, call the Skill tool with `prototype`, and record the chosen variant with its link. On plain, record that the look is plain on purpose.

Do domain work during the interview:

- **Challenge**: when the user uses a word that conflicts with the glossary, say so at once and ask which meaning is correct.
- **Sharpen**: when a word is vague, propose one exact term.
- **Probe**: test each relationship between concepts with a concrete scenario at its edge.
- **Cross-check**: when the user says how something works, compare it with the code, and show each contradiction.

When another question can be answered only by seeing or running something, such as how a state model behaves, offer the `prototype` skill. Record its verdict in the decisions log.

Completion: the interview returned the decisions log, with each decision above settled.

## 4. Size

A **spec** is one feature that a user can demo, and one PR that a reviewer reads in one sitting: about 2000 changed lines or fewer, tests included. Estimate the lines from the stories and the files that they touch.

- **One spec**: the estimate fits. Go to step 5 with one spec.
- **Project**: the estimate does not fit. Cut the stories into 2 to 5 child specs.

Cut a project by user value, never by layer. Each child spec is a vertical slice that works end to end, and ships alone with its own stories. The first child spec that needs a schema change takes the change, with the first behavior that uses it. A child spec that needs another to merge first is blocked by it. Name only a spec that truly gates it.

Completion: you have one spec, or 2 to 5 child specs with their stories and blocking edges.

## 5. Draft

Write the spec from the decisions log with [SPEC-TEMPLATE.md](../prd/SPEC-TEMPLATE.md). `/prd` owns the template, so both skills share it. Its `Domain changes` section takes the terms and ADR candidates of the log, and nothing else.

For a project, write each child spec with the template, with its own stories, numbered from 1. Put each term and ADR in the `Domain changes` of the first child spec that uses it. The project issue has the `Problem`, `Solution` and `Out of scope` sections of the template, and a `Specs` section in place of the rest: one line per child spec, `<ref>. <title> · blocked by: <refs, or none>`.

This is the one approval of the spec. In the chat, show only what the user approves, one short line each:

```markdown
You approve:
- Problem: <who has it, and what it costs them>
- Scope: <what the feature does>
- Out of scope: <each item>
- Seams: <each seam>
- Schema: <each migration, or none>
- Look: <the chosen variant with its link, or plain>
- Stories: <count>, <a title of a few words for each>
- Domain: <each new term and ADR, or none>
```

For a project, the list has the problem, out of scope and seams once, then one block per child spec:

```markdown
- <ref>. <title> · blocked by: <refs, or none>
  Stories: <count>, <a title of a few words for each> · Schema: <each migration, or none> · Domain: <each term and ADR, or none>
```

The issue has the full text. Ask with the question tool: "Approve" or "Change". On Change, apply the edits, show the list again and ask again.

When the draft needs a term or a decision that is not in the log, ask the user about it before you publish. Add it to the log only when the user agrees.

Completion: the user approved the draft, and each term in the draft is in the log.

## 6. Publish

Call the Skill tool with `issue` to create the spec issue with the `spec` label. For a project, hand it one list: the project issue with the `project` label, then each child spec with the `spec` label, the project as its parent, and its blockers by ref.

Then delete the decisions log file. The spec issue is now the record.

Completion: each issue exists, you have each number, and the log file is gone.

## Report

Spec issue URL, or the project URL with each child spec · terms and ADRs in each `Domain changes` section · next step: `/build <n>` for the spec, or for each child spec that has no blocker.
