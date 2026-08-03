# Skills v1.1

Adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills), plus the delivery lifecycle (`ticket-done`, `spec-done`, `cleanup`) which has no upstream. Split by how each skill is reached — nothing deeper, since skills install by leaf name anyway.

Run [`setup-skills`](./user-invoked/setup-skills/SKILL.md) once per repo before anything else.

## User-invoked

Reachable only when you type them (`disable-model-invocation: true`). Start at [`ask`](./user-invoked/ask/SKILL.md) if you don't remember which one you want.

- **[ask](./user-invoked/ask/SKILL.md)** — router over everything here: which skill or flow fits your situation.
- **[setup-skills](./user-invoked/setup-skills/SKILL.md)** — configure the repo: issue tracker, triage labels, domain doc layout, delivery shape, worktree provisioner. Once per repo.
- **[grill-with-docs](./user-invoked/grill-with-docs/SKILL.md)** — grilling that also builds the domain model, updating `CONTEXT.md` and ADRs inline.
- **[wayfinder](./user-invoked/wayfinder/SKILL.md)** — plan an effort too big for one session as a shared map of decision tickets, resolved one at a time until the way is clear.
- **[to-spec](./user-invoked/to-spec/SKILL.md)** — turn the current conversation into a spec on the issue tracker.
- **[to-tickets](./user-invoked/to-tickets/SKILL.md)** — break a plan into tracer-bullet tickets, each declaring its blocking edges and the user stories it satisfies, with a traceability table written back into the spec.
- **[implement](./user-invoked/implement/SKILL.md)** — build the work, driving `/tdd` at pre-agreed seams. Creates and provisions the spec's worktree once, then builds one ticket per task branch.
- **[ticket-done](./user-invoked/ticket-done/SKILL.md)** — tight per-ticket gate: cold-read, scoped checks and `/simplify` fired in one turn, commit, PR into the feature branch, squash-merge, close the issue, cut the next.
- **[spec-done](./user-invoked/spec-done/SKILL.md)** — conformance gate, once per spec: walk the traceability table, rebase onto the trunk, full suite, cross-ticket simplify, `/code-review` against the spec, open the PR. Never merges.
- **[cleanup](./user-invoked/cleanup/SKILL.md)** — post-merge teardown, once per spec: close the spec issue, remove the worktree, delete branches, drop the scratch DB, reclaim Docker, refresh the trunk.
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

## The three units

**Worktree** — horizontal. One isolated checkout per **spec**, worked in parallel with other specs. Provisioned once; every ticket in it shares the env, the ports, and the DB.
**Feature branch** — the integration branch inside the worktree, cut once off the trunk. Every ticket merges here; it merges to the trunk once, by hand.
**Task branch** — vertical. One per **ticket**: cut from the feature branch, its own PR, squash-merged back.

```
              ┌─ worktree A ─ feat/a ← [01 PR] ← [02 PR] ← [03 PR] ─┐
specs ────────┼─ worktree B ─ feat/b ← [01 PR] ← [02 PR] ──────────┼─► trunk (merged by hand)
              └─ worktree C ─ feat/c ← [01 PR] ─────────────────────┘
```

The blocking edges from `to-tickets` order the tickets, then git holds them — ticket N+1 is cut from a feature branch that already contains N, so nothing needs unlocking and no rebase cascades. The cost: the DAG is serialized inside a spec, so tickets worth running at the same time want separate specs.

A per-ticket PR is worth it even solo: the AI wrote the code and you haven't read it, so that PR is your post-merge first read — the audit trail. Work too small for a spec takes **light mode**: one task branch off the trunk, `/ticket-done` opens its PR to the trunk and stops.

**Three closures.** Ticket closes when its PR squash-merges into the feature branch (unblocking the next). Spec closes when the feature branch merges to the trunk. Release closes when it deploys — a project-local skill, outside this pipeline.

Two gates, sized differently: [`ticket-done`](./user-invoked/ticket-done/SKILL.md) runs on every ticket and stays scoped to the diff; [`spec-done`](./user-invoked/spec-done/SKILL.md) runs once and carries everything that scales with the spec.

## Dropped

From v1: `reconcile-branch` (its trigger collided with `resolving-merge-conflicts`; its diff-verification survives as that skill's step 7), `two-axis-review` (superseded by upstream `code-review`), `grill-me` (it was `grilling` with the docs off), `teach`, `seo-geo-audit`.

From v1.1: `ship` — with no stack to sync and no skill permitted to merge, its whole job collapsed into `spec-done`'s final step.
