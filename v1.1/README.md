# Skills v1.1

Adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills), plus the delivery lifecycle (`ticket-done`, `feature-done`, `ship`, `cleanup`) which has no upstream. Split by how each skill is reached — nothing deeper, since skills install by leaf name anyway.

Run [`setup-skills`](./user-invoked/setup-skills/SKILL.md) once per repo before anything else.

## User-invoked

Reachable only when you type them (`disable-model-invocation: true`). Start at [`ask`](./user-invoked/ask/SKILL.md) if you don't remember which one you want.

- **[ask](./user-invoked/ask/SKILL.md)** — router over everything here: which skill or flow fits your situation.
- **[setup-skills](./user-invoked/setup-skills/SKILL.md)** — configure the repo: issue tracker, triage labels, domain doc layout, delivery shape, worktree provisioner. Once per repo.
- **[grill-with-docs](./user-invoked/grill-with-docs/SKILL.md)** — grilling that also builds the domain model, updating `CONTEXT.md` and ADRs inline.
- **[wayfinder](./user-invoked/wayfinder/SKILL.md)** — plan an effort too big for one session as a shared map of decision tickets, resolved one at a time until the way is clear.
- **[to-spec](./user-invoked/to-spec/SKILL.md)** — turn the current conversation into a spec on the issue tracker.
- **[to-tickets](./user-invoked/to-tickets/SKILL.md)** — break a plan into tracer-bullet tickets, each declaring its blocking edges.
- **[implement](./user-invoked/implement/SKILL.md)** — build the work, driving `/tdd` at pre-agreed seams. Creates and provisions the feature's worktree, then builds one ticket per layer.
- **[ticket-done](./user-invoked/ticket-done/SKILL.md)** — tight per-ticket gate: cold-read and scoped checks in parallel, commit, publish this layer's PR, open the next.
- **[feature-done](./user-invoked/feature-done/SKILL.md)** — conformance gate, once per feature: simplify the full diff, full suite, `/code-review` against the spec, then hand to ship.
- **[ship](./user-invoked/ship/SKILL.md)** — integrate, push, PR. Solo branch or whole stack. Never merges.
- **[cleanup](./user-invoked/cleanup/SKILL.md)** — post-merge teardown: unstack, remove the worktree, delete branches, drop the scratch DB, reclaim Docker, refresh main.
- **[triage](./user-invoked/triage/SKILL.md)** — move incoming issues through a state machine of triage roles.
- **[improve-codebase-architecture](./user-invoked/improve-codebase-architecture/SKILL.md)** — scan for deepening opportunities, report visually, then grill through the one you pick.
- **[handoff](./user-invoked/handoff/SKILL.md)** — compact the conversation into a file a fresh session can pick up.
- **[writing-great-skills](./user-invoked/writing-great-skills/SKILL.md)** — reference for writing and editing skills well.

## Model-invoked

Model- or user-reachable — rich trigger phrasing so the model can reach for them, and so other skills can.

- **[grilling](./model-invoked/grilling/SKILL.md)** — the relentless one-question-at-a-time interview. The shared primitive.
- **[tdd](./model-invoked/tdd/SKILL.md)** — red-green-refactor, one vertical slice at a time.
- **[prototype](./model-invoked/prototype/SKILL.md)** — throwaway code to answer a design question: a runnable terminal app for state/logic, or toggleable UI variations.
- **[research](./model-invoked/research/SKILL.md)** — background agent that investigates against primary sources, leaving a cited Markdown file.
- **[diagnosing-bugs](./model-invoked/diagnosing-bugs/SKILL.md)** — reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[resolving-merge-conflicts](./model-invoked/resolving-merge-conflicts/SKILL.md)** — resolve an in-progress merge/rebase hunk by hunk, then verify the surviving diff is exactly the intended change.
- **[code-review](./model-invoked/code-review/SKILL.md)** — two-axis review of a diff: Standards (repo standards + Fowler smell baseline) and Spec (faithful to the originating issue?), as parallel sub-agents.
- **[domain-modeling](./model-invoked/domain-modeling/SKILL.md)** — sharpen the project's domain language; record decisions as ADRs.
- **[codebase-design](./model-invoked/codebase-design/SKILL.md)** — deep-module vocabulary: a lot of behaviour behind a small interface at a clean seam.

## The two units

**Worktree** — horizontal. One isolated checkout per **feature**, worked in parallel with other features.
**Layer** — vertical. One per **ticket**: its own branch, its own PR, reviewable the moment it seals.

A stack lives in one worktree. A cascading rebase must move every branch in the chain, and git refuses to touch a branch checked out elsewhere.

```
              ┌─ worktree A ─ stack ─ ticket1 PR ← ticket2 PR ← ticket3 PR ─┐
specs ────────┼─ worktree B ─ stack ─ ticket1 PR ← ticket2 PR ──────────────┼─► trunk
              └─ worktree C ─ single branch ─ PR ───────────────────────────┘
```

The blocking edges from `to-tickets` order the layers, then git holds them — ticket N's branch is based on N-1's, so nothing needs unlocking. The cost: a stack serializes the DAG, so tickets worth running at the same time want separate specs.

Without stacked PRs the shape collapses to **solo** — the feature is one branch, tickets are commits, one PR at the end (worktree C above). Same gates, but you review the feature whole rather than ticket by ticket.

Two gates, sized differently: [`ticket-done`](./user-invoked/ticket-done/SKILL.md) runs on every ticket and stays scoped to the diff; [`feature-done`](./user-invoked/feature-done/SKILL.md) runs once and carries everything that scales with the feature.

## Dropped from v1

`reconcile-branch` (its trigger collided with `resolving-merge-conflicts`; its diff-verification survives as that skill's step 7), `two-axis-review` (superseded by upstream `code-review`), `grill-me` (it was `grilling` with the docs off), `teach`, `seo-geo-audit`.
