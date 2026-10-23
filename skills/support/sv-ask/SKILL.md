---
name: sv-ask
description: "Pick the sv- skill or flow for the work at hand, from the state of the repo. Use when the user runs /sv-ask, asks which skill fits or what to run next, or at the start of work when no sv- skill was named."
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

This skill is a router over the `sv-` skills. It names the next command and the reason. It runs no other skill and changes nothing.

The summaries here are for orientation. Before you say what a skill does, or that a step can be skipped, read that skill's `SKILL.md`.

## 1. Read the state

Find the facts below. Use git, `gh` and the files. Ask the user only for a fact that the repo cannot give.

- **Setup**: `AGENTS.md` has an `## Agent skills` block, or it does not.
- **Branch**: the current branch, and its kind from the name: `spec/<n>-<slug>`, `ticket/<n>-<slug>`, `fix/<n>-<slug>`, the trunk, or other.
- **Git operation**: a rebase or a merge stops on a conflict, or none is in progress.
- **Issue**: for a spec, ticket or fix branch, the state of issue `<n>`. For a spec, its open tickets and their blockers.
- **PR**: for a spec or fix branch, an open PR, a merged PR, or none.
- **Request**: what the user wants, in one line.

Completion: you have each fact, or you know that it does not apply.

## 2. Route

Go down the tree. The first match is the answer.

```text
A rebase or merge stops on a conflict ─────────► sv-resolve-conflicts
File or track work for later (idea, bug) ──────► /sv-issue
Branch has a merged PR ────────────────────────► /sv-cleanup
Branch has an open PR ─────────────────────────► you merge, then /sv-cleanup
Something is broken (error, Sentry, bug) ──────► /sv-diagnose
fix/ branch, fix committed, no PR ─────────────► /sv-ship
fix/ branch, issue has an approach: label ─────► /sv-build <issue> (it resumes)
fix/ branch, no fix commit yet ────────────────► /sv-diagnose <issue>
ticket/ branch ────────────────────────────────► /sv-build <ticket> (it resumes)
spec/ branch
  ├── spec issue has no tickets ───────────────► /sv-plan
  ├── an open ticket has no open blockers ─────► /sv-build <ticket>
  ├── all tickets closed, no review comment ───► /sv-review
  └── review comment approved ─────────────────► /sv-ship
New idea or feature
  ├── no setup, or the user wants a PRD only ──► /sv-prd
  ├── no setup, the user wants the full flow ──► /sv-setup-skills, then /sv-spec
  └── setup done ──────────────────────────────► /sv-spec
A one-off change with a known result ──────────► /sv-issue task, then /sv-build <issue>
A design question that talk cannot settle ─────► sv-prototype
Stress-test a plan or decision ────────────────► sv-interview
Check a diff ──────────────────────────────────► /sv-verify
Check a change in a browser ───────────────────► /sv-ui-check
Change structure, keep behavior ───────────────► sv-refactor
Build one behavior test-first, with no spec ───► sv-tdd
Write a PR body ───────────────────────────────► sv-pr
Make, provision or remove a worktree ──────────► sv-worktree
End of a day of work ──────────────────────────► /sv-retro
Edit a skill, AGENTS.md or CLAUDE.md ──────────► sv-writing-for-agents
Cut AI tells from text ────────────────────────► sv-unslop
```

When no branch matches, say so, and give the two nearest skills with the difference between them.

Completion: you have one command, or one command for each part of a request with several parts.

## 3. Answer

Give the answer in this shape:

```text
Next: /sv-<skill> <argument>
Why: <the facts from step 1 that chose it>
Then: <the command after it in the flow>
```

When the state skips a step of the flow, name the step and the fact that skips it.

When the user asks for a step out of order, name the command that the flow puts first and its reason. The user decides.

## The flows

```text
Feature:  /sv-spec ──► /sv-plan ──► /sv-build (one per ticket) ──► /sv-review ──► /sv-ship ──► you merge ──► /sv-cleanup
Bug:      /sv-diagnose ──► /sv-ship ──► you merge ──► /sv-cleanup
One-off:  /sv-issue ──► /sv-build ──► /sv-ship ──► you merge ──► /sv-cleanup
No setup: /sv-prd ──► you start the tickets
```

- `/sv-build` and `/sv-diagnose` run `/sv-verify` themselves. The user runs it by hand only on another diff.
- `/sv-build` calls `sv-tdd`, `sv-refactor` or `sv-diagnose` from the `approach:` label of the ticket.
- `/sv-issue` files an idea, a bug or a task with the context that the conversation has, so the next skill starts from the issue. When the user wants to track several parts of a request, route the whole request to `/sv-issue`: it files each part and the blocking edges between them.
- Route a task or ticket to `/sv-build`, which picks the approach skill.
- `/sv-spec`, `/sv-plan`, `/sv-build`, `/sv-review`, `/sv-ship` and `/sv-cleanup` need `/sv-setup-skills`. `/sv-prd`, `/sv-issue`, `/sv-diagnose`, `sv-tdd` and `sv-refactor` run without it.
- Each `/sv-build` runs in its own session. The user picks how many run at the same time.
- Skills with no slash in this file are called by other skills. The user can also run them directly.
