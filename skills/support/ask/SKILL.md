---
name: ask
description: "Pick the skill of this set, or the flow, for the work at hand, from the state of the repo. Use when the user runs /ask, asks which skill fits or what to run next, or at the start of work when no skill of this set was named."
metadata:
  credits:
    - skill: ask-matt
      author: Matt Pocock
      organisation: AI Hero
      url: "https://github.com/mattpocock/skills/blob/main/skills/engineering/ask-matt/SKILL.md"
    - skill: using-agent-skills
      author: Addy Osmani
      organisation: agent-skills
      url: "https://github.com/addyosmani/agent-skills/blob/main/skills/using-agent-skills/SKILL.md"
---

# Ask

This skill is a router over the skills of this set. It names the next command and the reason. It runs no other skill and changes nothing.

The summaries here are for orientation. Before you say what a skill does, or that a step can be skipped, read that skill's `SKILL.md`.

## 1. Read the state

Find the facts below. Use git, `gh` and the files. Ask the user only for a fact that the repo cannot give.

- **Branch**: the current branch: `fix/<n>-<slug>`, the trunk, or other.
- **Git operation**: a rebase or a merge stops on a conflict, or none is in progress.
- **Issue**: the issue in the branch name or the request, its state and its kind. For a spec, its open tickets and their blockers.
- **PR**: for a branch that is not the trunk, an open PR, a merged PR, or none.
- **Request**: what the user wants, in one line.

Completion: you have each fact, or you know that it does not apply.

## 2. Route

Go down the tree. The first match is the answer.

```text
A rebase or merge stops on a conflict ─────────► resolve-conflicts
File or track work for later (idea, bug) ──────► /issue
Branch has a merged PR ────────────────────────► /cleanup
Branch has a draft PR ─────────────────────────► /ship
Branch has an open PR ─────────────────────────► you merge, then /cleanup
Something is broken (error, Sentry, bug) ──────► /diagnose
fix/ branch with commits, no PR ───────────────► /ship
Spec issue with open tickets ──────────────────► /build <ticket with no open blocker>
Any other ticket or task, or a small change ───► /build <issue or words>
New idea or feature with stories to settle ────► /spec
Research, look up or compare a topic ─────────► /research
A design question that talk cannot settle ─────► prototype
Stress-test a plan or decision ────────────────► interview
Close a phase of built work ───────────────────► phase-done
Check a diff ──────────────────────────────────► /verify
Check a change in a browser ───────────────────► /ui-check
Change structure, keep behavior ───────────────► refactor
Build one behavior test-first, with no spec ───► tdd
Write a PR body ───────────────────────────────► pr
Make, provision or remove a worktree ──────────► worktree
Once a week of work ───────────────────────────► /retro
Edit a skill, AGENTS.md or CLAUDE.md ──────────► writing-for-agents
Cut AI tells from text ────────────────────────► unslop
Explain a ticket in plain terms ───────────────► /brief
A manual step: keys, CI secrets, a cutover ────► /wizard
```

When no branch matches, say so, and give the two nearest skills with the difference between them.

Completion: you have one command, or one command for each part of a request with several parts.

## 3. Answer

Give the answer in this shape:

```text
Next: /<skill> <argument>
Why: <the facts from step 1 that chose it>
Then: <the command after it in the flow>
```

When the state skips a step of the flow, name the step and the fact that skips it.

When the user asks for a step out of order, name the command that the flow puts first and its reason. The user decides.

## The flows

```text
Feature:  /spec ──► /build, once per ticket ──► /ship ──► you merge ──► /cleanup
Ticket:   you write it ──► /build ──► /ship ──► you merge ──► /cleanup
Bug:      /diagnose ──► /ship ──► you merge ──► /cleanup
```

- Each `/build` works in your session, on one ticket: plan, one approval, build, then `phase-done` for each phase. A hard stop gets the full plan in that session.
- `/build` picks `tdd`, `refactor` or `diagnose` from the work, or builds directly.
- `/ship` runs the hard-stop check and pushes a draft PR. Then the one cold read runs while CI does the full check.
- Every skill runs alone, with no earlier step. `/setup-skills` is optional.
- Skills with no slash in this file are called by other skills. The user can also run them directly.
