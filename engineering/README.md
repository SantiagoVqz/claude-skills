# Engineering

The build pipeline and the code skills around it, grouped by pipeline phase. Run [`setup/setup-skills`](./setup/setup-skills) once per repo before using the tracker-backed skills (`to-spec`, `to-tickets`, `triage`, `wayfinder`).

## The flow

```
idea ──/grilling──► /to-spec ──► /to-tickets ──► /implement ──► /ship
                                     ▲
        big effort, many sessions ──/wayfinder
```

Skills install by their leaf name, so the sub-folders below are organizational only — `/grilling` is the same skill whether it lives in `plan/` or anywhere else.

## plan/ — sharpen the idea before writing code

| Skill | Purpose |
|-------|---------|
| [`grilling`](./plan/grilling) | Relentless one-question-at-a-time interview to sharpen a plan before building. The shared primitive other skills call. |
| [`grill-with-docs`](./plan/grill-with-docs) | Same interview as `grilling`, but writes ADRs + glossary as decisions crystallise. |
| [`wayfinder`](./plan/wayfinder) | Plan a huge effort — more than one session can hold — as a shared map of investigation tickets. |
| [`research`](./plan/research) | Background agent that investigates a question against primary sources, leaving a cited Markdown file. |
| [`prototype`](./plan/prototype) | Build throwaway code to answer a design question. |
| [`domain-modeling`](./plan/domain-modeling) | Build and sharpen a project's domain model. |
| [`codebase-design`](./plan/codebase-design) | Shared vocabulary for designing deep modules. |

## spec/ — turn the plan into tracked work

| Skill | Purpose |
|-------|---------|
| [`to-spec`](./spec/to-spec) | Turn the current conversation into a spec (a.k.a. PRD) and publish it to the tracker. |
| [`to-tickets`](./spec/to-tickets) | Break a plan/spec/conversation into tracer-bullet tickets with blocking edges, published to the tracker. |

## build/ — write the code

| Skill | Purpose |
|-------|---------|
| [`implement`](./build/implement) | Implement a piece of work from a spec or set of tickets, driving TDD and code review. |
| [`phase-done`](./build/phase-done) | Per-phase closer for multi-phase work: simplify, run the repo's own checks, commit, then a cold-read review by a fresh agent. (Mine — no upstream.) |
| [`tdd`](./build/tdd) | Test-driven development — the red → green loop, reference-only. |

## review/ — check and maintain the code

| Skill | Purpose |
|-------|---------|
| [`code-review`](./review/code-review) | Review changes on two axes: repo Standards + a Fowler code-smell baseline. |
| [`improve-codebase-architecture`](./review/improve-codebase-architecture) | Scan for module-deepening opportunities, report visually, then grill through the one you pick. |
| [`reconcile-branch`](./review/reconcile-branch) | Bring a branch up to date with its base and confirm the surviving diff is exactly intended. (Mine — no upstream.) |
| [`ship`](./review/ship) | Push the current branch and open (or report) its PR — the external-git half of the lifecycle after `/implement`. (Mine — no upstream.) |
| [`cleanup`](./review/cleanup) | Post-merge teardown of a finished ticket — worktree or plain branch: remove the worktree, delete the local + remote branch, drop any per-branch DB, prune, refresh main. (Mine — no upstream.) |
| [`triage`](./review/triage) | Move issues and external PRs through a state machine of triage roles. |

## setup/ — one-time per-repo config

| Skill | Purpose |
|-------|---------|
| [`setup-skills`](./setup/setup-skills) | Configure the issue tracker, triage labels, and domain doc layout. Run once per repo. |
