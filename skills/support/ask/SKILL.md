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

- **Setup**: `AGENTS.md` has an `## Agent skills` block, or it does not.
- **Branch**: the current branch, and its kind from the name: `spec/<n>-<slug>`, `fix/<n>-<slug>`, the trunk, or other.
- **Git operation**: a rebase or a merge stops on a conflict, or none is in progress.
- **Issue**: for a spec or fix branch, or a spec named in the request, the state of issue `<n>`. For a spec, whether it has a `### Review of` comment with the hash of the branch head. For a project, its child specs and their blockers.
- **PR**: for a spec or fix branch, an open PR, a merged PR, or none.
- **Request**: what the user wants, in one line.

Completion: you have each fact, or you know that it does not apply.

## 2. Route

Go down the tree. The first match is the answer.

```text
A rebase or merge stops on a conflict ─────────► resolve-conflicts
File or track work for later (idea, bug) ──────► /issue
Branch has a merged PR ────────────────────────► /cleanup
Branch has an open PR ─────────────────────────► you merge, then /cleanup
Something is broken (error, Sentry, bug) ──────► /diagnose
fix/ branch, review comment at the head ───────► /ship
fix/ branch, commits after the review comment ─► /final-review <issue>
fix/ branch, issue has an approach: label ─────► /build <issue> (it resumes)
fix/ branch, bug fix committed, no PR ─────────► /ship
fix/ branch, no fix commit yet ────────────────► /diagnose <issue>
Project issue ─────────────────────────────────► /build <child spec with no open blocker>
Spec issue
  ├── review comment at the branch head ───────► /ship <spec>
  ├── commits after the review comment ────────► /final-review <spec>
  └── no review comment ───────────────────────► /build <spec> (it plans or resumes)
New idea or feature
  ├── no setup, or the user wants a PRD only ──► /prd
  ├── no setup, the user wants the full flow ──► /setup-skills, then /spec
  └── setup done ──────────────────────────────► /spec
A one-off change with a known result ──────────► /issue task, then /build <issue>
Research, look up or compare a topic ─────────► /research
A design question that talk cannot settle ─────► prototype
Stress-test a plan or decision ────────────────► interview
Check a diff ──────────────────────────────────► /verify
Check a change in a browser ───────────────────► /ui-check
Change structure, keep behavior ───────────────► refactor
Build one behavior test-first, with no spec ───► tdd
Write a PR body ───────────────────────────────► pr
Make, provision or remove a worktree ──────────► worktree
End of a day of work ──────────────────────────► /retro
Edit a skill, AGENTS.md or CLAUDE.md ──────────► writing-for-agents
Cut AI tells from text ────────────────────────► unslop
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
Feature:  /spec ──► /build (plan, all phases, final-review) ──► /ship (PR, CI) ──► you merge ──► /cleanup
Project:  /spec ──► the Feature flow from /build, once per child spec, in blocking order
Bug:      /diagnose ──► /ship ──► you merge ──► /cleanup
One-off:  /issue ──► /build ──► /ship ──► you merge ──► /cleanup
No setup: /prd ──► you start the tickets
```

- `/build` and `/diagnose` run `/verify` themselves. The user runs it by hand only on another diff.
- `/build` calls `tdd`, `refactor` or `diagnose` from the approach of each phase, in a subagent, then calls `final-review`. The user iterates at its card.
- `/issue` files an idea, a bug or a task with the context that the conversation has, so the next skill starts from the issue. When the user wants to track several parts of a request, route the whole request to `/issue`: it files each part and the blocking edges between them.
- Route a task or ticket to `/build`, which picks the approach skill.
- `/spec`, `/build`, `/final-review`, `/ship` and `/cleanup` need `/setup-skills`. `/prd`, `/issue`, `/diagnose`, `tdd` and `refactor` run without it.
- `/spec` makes no branch. `/build` makes the branch and its worktree.
- Each `/build` runs in its own session. Two specs can build at the same time, in two sessions.
- Skills with no slash in this file are called by other skills. The user can also run them directly.
