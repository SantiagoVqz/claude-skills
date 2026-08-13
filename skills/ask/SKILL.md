---
name: ask
description: Ask which skill or flow fits your situation. A router over the skills in this repo.
disable-model-invocation: true
---

# Ask

You don't remember every skill, so ask. A **flow** is a path through the skills: most work travels the main flow, two on-ramps merge onto it, and the rest run underneath or alongside.

## Precondition

**`/setup-skills`** — run once per repo before the first flow. It configures the issue tracker (GitHub, GitLab, Linear, or local markdown), the triage labels, the domain-doc layout, and worktree/Docker provisioning (`scripts/provision.sh`).

## The main flow: idea → merged

1. **`/grill`** — sharpen the idea by relentless interview. It runs the `/grilling` engine together with `/domain-modeling`, so `CONTEXT.md` and ADRs are maintained as decisions land — the paper trail is built in. If a question needs a runnable answer (state, logic, a UI you have to see), detour through **`/prototype`** and fold what you learn back into the thread.
2. **`/spec`** — collapse the grilled thread into a spec on the tracker. Skip it only when the work is small enough to implement in the same session.
3. **`/tickets`** — cut the spec into tracer-bullet vertical slices with blocking edges (logical and same-code-area), each independently demoable so each can land on trunk alone.
4. **Per frontier ticket, trunk-based** — worktree + branch off the trunk (provision per `scripts/provision.sh`), then:
   - **`/implement <ticket>`** in the worktree — drives `/tdd` one red-green slice at a time, verifies, commits.
   - **`/ship`** — rebase onto trunk, full suite, push, PR carrying `Closes #<ticket>`. Never merges.
   - **You merge.**
   - **`/cleanup`** — verify the issue closed, tear down worktree/branch/scratch DB/Docker leftovers, refresh trunk.

   Frontier tickets run in parallel, one worktree + pane each. When the trunk has moved far enough that the diff needs auditing rather than a plain rebase, **`/reconcile-branch`** instead of `/ship`'s rebase step.

Keep steps 1–3 in one unbroken context window so the grilling, spec, and tickets build on the same thinking; each `/implement` then starts fresh from its ticket.

## On-ramps

- **Bugs and requests piling up** → **`/triage`**. Moves issues through the triage roles and produces agent-ready briefs that `/implement` later picks up. Only for issues you didn't create — `/tickets` output is already agent-ready, so don't triage it.
- **A huge, foggy effort — too big for one session** → **`/wayfinder`**. Charts a shared map of decision tickets on the tracker and resolves them one at a time — decisions, not deliverables — until the way is clear. It calls `/grilling`, `/research`, and `/prototype` per ticket type. When the map clears, merge onto the main flow at `/spec`; never loop the map straight into `/implement` unless the effort turned out genuinely small.

## Underneath and alongside

- **`/grilling`** — the interview engine itself: rounds, the frontier, facts are the agent's job and decisions are yours. `/grill` is the named way in; `/triage` and `/wayfinder` run it internally.
- **`/domain-modeling`** — the active glossary/ADR discipline: challenge fuzzy terms, update `CONTEXT.md` inline, record hard-to-reverse decisions as ADRs. `/grill`, `/triage`, and `/wayfinder` pair it with `/grilling`.
- **`/tdd`** — the red → green reference: seams, anti-patterns, rules of the loop. `/implement` drives it; reach for it alone to build one behaviour test-first without a full spec.
- **`/research`** — delegate reading legwork to a background agent that investigates against primary sources and leaves a cited markdown file. Feeds the thinking at `/grill`; doesn't replace it.
- **`/prototype`** — throwaway code that answers one design question (logic demo or UI variations). The answer folds into the real code; the prototype survives on a `prototype/<name>` branch as a primary source.
- **`/resolving-merge-conflicts`** — work an in-progress merge/rebase conflict hunk by hunk, resolving by intent traced to each side's primary source. `/ship` and `/reconcile-branch` hand off to it; reach for it directly when already mid-conflict.
