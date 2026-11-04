---
name: build
description: "Plan and build one ticket in this session: read it and the code, check the hard stops, get one approval, pick the approach, and implement. Also takes the next ticket of a spec, or a change in words."
disable-model-invocation: true
argument-hint: "<ticket | spec | words>"
---

# Build

`/build` takes one ticket to one commit on a branch, in this session, ready for `/ship`. The user sees the work as it happens, and can change it at any point. It is **light by default**: a short plan and one approval. A hard stop gets the full plan, in this same session.

## 1. Read

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, read `NO-SETUP.md` in the folder of the `setup-skills` skill, and go on with its sources. Read the issue with its comments and its parent.

Find what the argument is. A label such as `Remissions` changes nothing here.

- **Spec or project with open sub-issues**: stop. Name each open sub-issue with no open blocker. The next step is `/build <that issue>`.
- **Idea**: stop. The next step is `/spec <n>`.
- **Spec with no sub-issues**: one ticket, with its stories as the criteria.
- **Words with no issue**: one ticket. The plan is the record, so write nothing to the tracker, and the branch is `fix/<slug>`.
- **Any other issue**: one ticket, also with no criteria yet.

Stop when an issue in `blockedBy` is open, and name it. When someone else has the issue, ask with the question tool: "Take over" or "Stop". When the branch exists and the issue has a `### Plan of #<n>` comment, switch to the branch, and resume at step 5 from its commits.

Read the code that the ticket touches, and `git log` on that area. Ask whether the ticket is a symptom of a cause one layer down.

Completion: you can name the current behavior or the cause, the fix, and the code that the fix changes.

## 2. Hard stops

A **hard stop** is a change that needs more than a short plan:

- a migration or a backfill
- auth or permission code
- a write to production data
- a new or materially changed user-visible UI element
- an API contract that another repo or app consumes
- the third issue on the same symptom: search all issues and `git log` for it

Each item is a class of past incident. Change the list only from `/retro` evidence.

A hard stop that the parent spec already settled stays light. Name it on the verdict line. For any other hard stop, or when the user asks for it, follow [PLAN.md](PLAN.md), then go to step 4. The user can say "stay light", with a reason.

Completion: you have the verdict line: `Hard stops: none`, or `Hard stops: <which> (<settled in #n, or override: reason>)`.

## 3. Plan

Write the plan in your message, in about 15 lines. A plan that needs more goes to [PLAN.md](PLAN.md).

```text
Issue: two or three sentences in plain terms, with no symbol names.
Cause: the cause or the current behavior, and your confidence in it.
Fix: the change, and the code that it touches.
Done when:
- each criterion, with the edge cases
Out of scope: what stays as it is.
Defaults: each choice that you took without asking.
Approach: from the table in step 5, with the reason in a few words.
Hard stops: the verdict line.
```

When the ticket already has criteria, use them word for word. Ask with the question tool: "Approve", "Change" or "Full plan". When the plan hinges on a real choice, add it as a second question in the same call, with your recommendation first. Two questions is the limit. Take a fact from the code, and take a default when the repo's rules settle the choice.

Completion: the user picked "Approve".

## 4. Set up

With an issue, as `tracker.md` says: add `## Acceptance criteria` at the end of the body when it has none, and keep the text that the person wrote. Post the plan as a comment that starts with `### Plan of #<n>`. Assign the issue to the user.

The branch is `fix/<n>-<slug>` from the trunk. Find the trunk as the `worktree` skill does. Make the branch in the primary checkout when that checkout is clean and on the trunk. Call the Skill tool with `worktree` when the checkout is busy, when the plan has a migration, or when the user asks: only then does the work need its own folder and databases.

When the parent spec has a `Domain changes` section that the trunk does not have yet, write it with [DOCS-FORMAT.md](DOCS-FORMAT.md), and commit: `Record terms and decisions for #<n>`.

Completion: the session is on the branch, and the issue has the plan.

## 5. Build

Pick the approach from the work, and call the Skill tool with its skill. Run nothing that the approach does not need.

| The work | Approach |
|---|---|
| Behavior with a clear test seam | `tdd` |
| A defect whose cause is unknown | `diagnose` |
| Structure only, and the behavior stays the same | `refactor` |
| Look, copy or config, with no seam that can test it | Build it directly, then run it and look |

A ticket can mix them, such as `tdd` for the logic and a direct build for the layout.

Work in this session. Delegate to one implementer subagent only when the work is large: over about 800 changed lines, or reads that would flood this context. Give it the shell rules below, the plan word for word, and the approach. A question from it comes to the user, and the answer goes back to the same subagent with `SendMessage`.

When the work shows a hard stop that the plan does not name, stop, and ask: "Stay light", with a reason, or "Full plan".

For a plan with phases, run this step and step 6 for each phase. After a phase of a multi-file migration or refactor, run `verify` in a new subagent on the diff of that phase. Other phases wait for the one cold read at `/ship`.

Completion: each criterion has its code.

## 6. Check and land

Run the typecheck, the lint, and the tests that the diff adds or touches. Leave the full suite to `/ship`. A failure is yours to fix now.

Squash into one commit, with one `-m` flag per paragraph:

- `<title> (#<n>)`
- one line for each criterion: `<criterion> · <test name, or what you saw>`
- `Hard stops: <the verdict>`, in the last paragraph, so that `/ship` can read it as a trailer. Any `Co-Authored-By` line goes right below it.

Then write your report, and stop. The user asks for changes in the chat: make each one, run this step again, and squash it into the same commit. Run `ui-check` only when the user asks.

Completion: the checks pass, the branch has one commit, and the report is in the chat.

## Shell rules

These apply in a worktree, and in each subagent prompt:

> Run one plain shell command per call, from the worktree root, on paths in the worktree. For a subfolder, use a flag such as `pnpm --dir` or `uv --directory`, because a `cd` stays in effect for the rest of the session. Change a file with the Edit tool, and make a new file with the Write tool. Quote each argument that holds `*`, `[` or `]`. The guard refuses only some other forms, such as a `&&` chain, `$(...)` or a heredoc, so a command that ran is no proof that its form is safe. Print no value from an env file, because a line such as `PROD_DATABASE_URL` holds a password. To see which variables a file sets, list the names only: `grep -oE '^[A-Z_]+=' <file>`. Run each test command in the foreground, with a timeout of up to 10 minutes. Only a run that needs longer goes in the background with its output in a file: wait for its exit notification, and read the result before you report. Ask before a host install, and stop an install that shows no progress for 5 minutes.

## Report

Each criterion with its test, or what you saw · the commit · the checks that ran · up to three steps for the user to check · next step: `/ship <n>`.
