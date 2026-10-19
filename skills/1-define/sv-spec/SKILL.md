---
name: sv-spec
description: "Turn an idea into a spec: interview, spec issue, spec branch, and the glossary and ADR changes."
disable-model-invocation: true
argument-hint: "[idea | issue]"
---

# Spec

`/sv-spec` is the start of a feature. It ends with four things: a spec issue that a team can read and comment on, a spec branch in its own worktree, the domain docs committed on that branch, and a user who agrees with all of it.

## 1. Load the setup

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md` and `docs/agents/domain.md`. When the block is missing, tell the user to run `/sv-setup-skills`, and stop.

Completion: you know how to create and label an issue in this repo.

## 2. Explore

Read the idea from the argument, or from the issue that it names. Then read the area of the code that the idea touches, the glossary that `docs/agents/domain.md` names, and the ADRs for that area.

Completion: you can describe in a few lines how the area works today.

## 3. Interview

Call the Skill tool with `sv-interview`. The design tree for a spec always contains these decisions, so the interview is not done until each one is settled:

- The problem, and the user who has it.
- The user stories.
- What is out of scope.
- The test seams. Propose the highest existing seam, and get the user's agreement.
- The schema changes: each migration, or none.
- The look of each new or changed screen, when the spec touches a screen. Ask "prototype it, or keep it plain?" On prototype, call the Skill tool with `sv-prototype`, and record the chosen variant with its link. On plain, record that the look is plain on purpose.

Do domain work during the interview:

- **Challenge**: when the user uses a word that conflicts with the glossary, say so at once and ask which meaning is correct.
- **Sharpen**: when a word is vague, propose one exact term.
- **Probe**: test each relationship between concepts with a concrete scenario at its edge.
- **Cross-check**: when the user says how something works, compare it with the code, and show each contradiction.

When another question can be answered only by seeing or running something, such as how a state model behaves, offer the `sv-prototype` skill. Record its verdict in the decisions log.

Completion: the user confirmed the decisions log with an explicit yes.

## 4. Draft

Write the spec from the decisions log with [SPEC-TEMPLATE.md](../sv-prd/SPEC-TEMPLATE.md). `/sv-prd` owns the template, so both skills share it. Show the draft to the user, and change it until they approve it.

When the draft needs a term or a decision that is not in the log, ask the user about it before you publish. Add it to the log only when the user agrees.

Completion: the user approved the draft, and each term in the draft is in the log.

## 5. Publish

Create the spec issue with the `spec` label.

Completion: the issue exists, and you have its number.

## 6. Branch

Call the Skill tool with `sv-worktree` for the branch `spec/<n>-<slug>`, made from the trunk.

Completion: the spec worktree exists and is provisioned.

## 7. Docs

Write only the terms and ADR candidates that are in the confirmed log. Add nothing else. When the log has terms or ADR candidates, write them in the spec worktree with [DOCS-FORMAT.md](DOCS-FORMAT.md). Commit them on the spec branch: `Record terms and decisions for #<n>`. Then delete the decisions log file. The spec issue is now the record.

Completion: each term and each ADR from the log is committed, or the log had none.

## Report

Spec issue URL · spec branch · worktree path · terms added · ADRs added · next step: `/sv-plan <n>`.
