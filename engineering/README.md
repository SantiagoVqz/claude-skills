# Engineering

The build pipeline and the code skills around it. Run [`setup-skills`](./setup-skills) once per repo before using the tracker-backed skills (`to-spec`, `to-tickets`, `triage`, `wayfinder`).

## The flow

```
idea ──/grilling──► /to-spec ──► /to-tickets ──► /implement ──► /code-review
                                     ▲
        big effort, many sessions ──/wayfinder
```

## Skills

| Skill | Purpose |
|-------|---------|
| [`grilling`](./grilling) | Relentless one-question-at-a-time interview to sharpen a plan before building. The shared primitive other skills call. |
| [`grill-with-docs`](./grill-with-docs) | Same interview as `grilling`, but writes ADRs + glossary as decisions crystallise. |
| [`to-spec`](./to-spec) | Turn the current conversation into a spec (a.k.a. PRD) and publish it to the tracker. |
| [`to-tickets`](./to-tickets) | Break a plan/spec/conversation into tracer-bullet tickets with blocking edges, published to the tracker. |
| [`implement`](./implement) | Implement a piece of work from a spec or set of tickets, driving TDD and code review. |
| [`tdd`](./tdd) | Test-driven development — the red → green loop, reference-only. |
| [`code-review`](./code-review) | Review changes on two axes: repo Standards + a Fowler code-smell baseline. |
| [`wayfinder`](./wayfinder) | Plan a huge effort — more than one session can hold — as a shared map of investigation tickets. |
| [`research`](./research) | Background agent that investigates a question against primary sources, leaving a cited Markdown file. |
| [`improve-codebase-architecture`](./improve-codebase-architecture) | Scan for module-deepening opportunities, report visually, then grill through the one you pick. |
| [`codebase-design`](./codebase-design) | Shared vocabulary for designing deep modules. |
| [`domain-modeling`](./domain-modeling) | Build and sharpen a project's domain model. |
| [`prototype`](./prototype) | Build throwaway code to answer a design question. |
| [`triage`](./triage) | Move issues and external PRs through a state machine of triage roles. |
| [`reconcile-branch`](./reconcile-branch) | Bring a branch up to date with its base and confirm the surviving diff is exactly intended. (Mine — no upstream.) |
| [`setup-skills`](./setup-skills) | One-time per-repo config: issue tracker, triage labels, domain doc layout. |
