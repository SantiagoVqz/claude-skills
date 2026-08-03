---
name: ask
description: Ask which skill or flow fits your situation. A router over the skills in this repo.
disable-model-invocation: true
---

# Ask

You don't remember every skill, so ask.

A **flow** is a path through the skills. Most paths run along one **main flow**, and two **on-ramps** merge onto it. Everything else is standalone, or a vocabulary layer that runs underneath.

## The main flow: idea → ship

The route most work travels. You have an idea and want it built.

1. **`/grill-with-docs`** — sharpen the idea by interview. Start here when you **have a codebase**: it's stateful, retaining what it learns in `CONTEXT.md` and ADRs. (No codebase? Use `/grilling` — see Standalone. Same interview; `grill-with-docs` is the one that leaves a paper trail.)
2. **Branch — can you settle every question in conversation?** If a question needs a runnable answer (state, business logic, a UI you have to see), detour through a prototype, bridged by **`/handoff`** in both directions (see Crossing sessions):
   - **`/handoff`** out, then open a fresh session against that file,
   - **`/prototype`** to answer the question with throwaway code,
   - **`/handoff`** back what you learned, and reference it from the original idea thread.
3. **Branch — is this a multi-session build?**
   - **Yes** → **`/to-spec`** (turn the thread into a spec), then **`/to-tickets`** to split it into tracer-bullet tickets, each declaring its **blocking edges** and the **user stories** it satisfies. On a local tracker that's one file per ticket under `.scratch/<feature>/issues/`, worked blockers-first by hand; on a real tracker the edges become native blocking links. Either way the edges set the **ticket order**, and a **traceability table** goes back into the spec issue — kick off **`/implement`**, which builds the tickets one at a time, **clearing context between each one**.
   - **No** → **`/implement`** right here, in the same context window. Work too small for a spec takes **light mode**: `/implement` runs its slice loop on one branch off the trunk, opens its PR to the trunk, and stops — you merge; no worktree, no `/spec-done`, no `/cleanup`.

   Either way, **`/implement`** builds each issue by driving **`/tdd`** internally — one red-green slice at a time. Reach for **`/tdd`** on its own when you just want to build a concrete behaviour test-first without a full spec, and **`/code-review`** on its own whenever you want to review a branch or PR against a fixed point.

4. **Land it** — see Landing the work below. `/implement` stops at committed code; getting it onto the remote and off your machine is two more skills.

## Landing the work

**One spec → one worktree → one feature branch → one gated commit per ticket.** Two units:

- **worktree** — horizontal. One per **spec**, worked in parallel with other specs. Provisioned once (env, ports, DB) and shared by every ticket in it.
- **feature branch** — the only branch, cut once off the trunk. Every ticket lands on it as one commit through `/implement`'s slice gate; it first reaches origin when `/spec-done` opens its PR.

The blocking edges from `/to-tickets` are consumed once, to order the tickets; after that git holds the dependency, since ticket N+1 starts on a feature branch that already contains ticket N's commit. Nothing has to be unlocked and no rebase cascades.

**Why one commit per ticket when you're solo.** Because the AI wrote the code and you haven't read it — the clean per-ticket commits and the spec PR are your first read, the audit trail. That's a stronger reason than a human team has.

**Three closures, three altitudes.** A unit's state tracks the thing that unit controls:

| Unit | Closes when | Closed by |
|---|---|---|
| **Ticket** — unit of work | its gated commit lands on the feature branch | `/implement`'s slice loop |
| **Spec** — unit of delivery | the feature branch merges to the trunk | `/cleanup` |
| **Release** — unit of value | deployed to production | your project's own release skill |

Two gates, sized differently. Running one gate at both sizes is what makes a build feel slow:

- **The slice gate** — inside `/implement`, per ticket, all three passes fired in *one* turn: a **cold-read** by a zero-context agent hunting the edit's residue, **`/simplify`** scoped to this slice's diff, and checks scoped to the diff's blast radius. Then one commit with a full body (stories, decisions, ticket ref), close the issue, clear context, next ticket.
- **`/spec-done`** — the **conformance** gate, once, when the last ticket lands: walk the **traceability table** (every story has a landed ticket, every ticket has a story), rebase onto the trunk, full suite, cross-ticket `/simplify` (duplication *between* tickets — the only part one slice couldn't see), `/code-review` against the spec, then **push, open the feature branch's PR to the trunk, and stop**. You verify in the still-standing worktree, push tweaks, and merge by hand.
- **`/resolving-merge-conflicts`** — fires whenever an integration stops on a conflict. Resolves by tracing each side's intent to its primary source, then verifies the surviving diff is exactly the intended change.
- **`/cleanup`** — after the PR merges, close the spec issue and reclaim the machine: remove the worktree, delete the branches, drop the per-worktree scratch DB, reclaim Docker leftovers, refresh the trunk. Once per spec — tickets need no teardown.

**No skill ever merges to the trunk.** `/spec-done` opens the feature's PR and stops. Landing the feature is always yours. Deploying is a project-local release skill — the global pipeline stops at "merged to trunk".

### Context hygiene

Keep steps 1–3 in **one unbroken context window** — don't compact or clear until after `/to-tickets` — so the grilling, spec, and tickets all build on the same thinking. Each `/implement` then starts fresh, working from the ticket.

The limit on this is the **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)**: the window (~120k tokens on state-of-the-art models) within which the model still reasons sharply. If a session approaches it before `/to-tickets`, don't push on degraded — `/handoff` and continue in a fresh thread.

## On-ramps

A starting situation that generates work, then merges onto the main flow.

- **Bugs and requests piling up** → **`/triage`**. It moves issues through triage roles and produces agent-ready issues, which **`/implement`** later picks up.

  Triage is only for issues **you didn't create** — bug reports, incoming feature requests, anything that arrives raw. Tickets that `/to-tickets` produced are already agent-ready, so **don't triage them**.

- **Something's broken** → **`/diagnosing-bugs`**. For the hard ones: the bug that resists a first glance, the intermittent flake, the regression that crept in between two known-good states. It refuses to theorise until it has a **tight feedback loop** — one command that already goes red on *this* bug — then fixes with a regression test. Its post-mortem hands off to **`/improve-codebase-architecture`** when the real finding is that there's no good seam to lock the bug down.

- **A huge, foggy effort — a greenfield project or a huge feature build, too big for one session** → **`/wayfinder`**, the most cognitively demanding flow here. When the way from here to the destination isn't visible yet, it charts a **shared map** of **decision tickets** on the issue tracker and resolves them one at a time — producing **decisions, not deliverables** — until the fog is pushed back and the way is clear. Where **`/grill-with-docs`** sharpens an idea you can hold in one session, wayfinder is for the idea you can't — and it's slower and denser, so save it for exactly that, never a well-scoped feature.

  When the map clears, **it hands off, it doesn't build**: merge onto the main flow at **`/to-spec`**, which collapses the map's linked decisions into a buildable plan, then `/to-tickets` and `/implement` as usual. Looping the map straight into `/implement` skips that collapse and throws the linked detail away — go straight to `/implement` only when the effort turned out genuinely small.

## Codebase health

Not feature work — upkeep.

- **`/improve-codebase-architecture`** — run whenever you have a spare moment to keep the codebase good for agents to operate in. It surfaces **deepening opportunities**; picking one _generates an idea_ you can take into the main flow at `/grill-with-docs`. It's the survey that finds the candidates; **`/codebase-design`** (below) is the bench you design the chosen one on.

## Vocabulary underneath

Two model-invoked references that run *beneath* the other skills — each the single source of truth for its vocabulary. Reach for them directly when the **words**, not the process, are the problem; or let the skills above pull them in.

- **`/domain-modeling`** — sharpen the project's *domain* language: challenge a fuzzy term, resolve an overloaded word ("account" doing three jobs), record a hard-to-reverse decision as an ADR. It's the active discipline `/grill-with-docs` drives to keep `CONTEXT.md` a clean glossary.
- **`/codebase-design`** — the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) for designing a module's *shape*: a lot of behaviour behind a small interface at a clean seam. `/tdd` and `/improve-codebase-architecture` both speak it.

## Crossing sessions

- **`/handoff`** — when a thread is full or you need to branch off (e.g. into a `/prototype` session), this compacts the conversation into a markdown file. You don't continue in place — you **open a new session and reference that file** to carry the context across. It's the bridge between context windows, in either direction. Use it when you want a **fresh session** but need the **current conversation preserved**.
- **`/compact`** (built-in) — stay in the **same conversation**, letting the earlier turns be summarized. Use it at the break each slice's commit opens, when you don't mind losing the verbatim history. Don't compact mid-ticket — the agent can lose its way. `/handoff` forks; `/compact` continues.

## Standalone

Off the main flow entirely.

- **`/grilling`** — the relentless one-question-at-a-time interview, bare. Stateless: it saves nothing locally, builds no `CONTEXT.md`. Reach for it to sharpen any plan or design that doesn't live in a repo; `/grill-with-docs` is the same interview with a paper trail.
- **`/prototype`** — a small, throwaway program that answers one design question: does this state model feel right, or what should this UI look like. Throwaway from day one — keep the answer, delete the code. It's the detour in step 2 of the main flow, but reach for it any time a design question is hard to settle on paper.
- **`/research`** — delegate reading legwork to a **background agent**: it investigates a question against **primary sources**, then leaves a cited Markdown file in the repo. Keep working while it reads. The file it produces is something to take *into* the main flow at `/grill-with-docs` — research feeds the thinking, it doesn't replace it.
- **`/writing-great-skills`** — reference for writing and editing skills well.

## Precondition

**`/setup-skills`** — run before your first engineering flow to configure the issue tracker, triage labels, doc layout, delivery shape (the trunk), and the worktree provisioner the other skills assume. Custom issue trackers also work.
