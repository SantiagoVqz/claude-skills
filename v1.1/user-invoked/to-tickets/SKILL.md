---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges and the user stories it satisfies, published to the configured tracker with a traceability table written back into the spec.
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-skills` if not.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window, which is also the size of a PR one person reviews in one sitting — **one ticket = one task branch = one PR into the feature branch**, so this sizing is what makes the review bearable
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**The edges decide ticket order, then git holds them.** A spec's tickets are built in one worktree on one feature branch: each ticket is a task branch cut from the feature branch and squash-merged back into it, so ticket N+1 is cut *after* ticket N merged. The dependency lives in the branch graph, not in a label anyone has to check. This **serializes** the DAG: tickets that could genuinely run in parallel won't. When two tracks are truly independent and worth working at the same time, that's a signal they want separate specs, so each gets its own worktree and its own feature branch.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

### 4. Build the traceability table

Map the spec's **numbered user stories** to the tickets that deliver them. One row per story:

| Story | Ticket |
|---|---|
| 1. As a customer, I want to see my cart total… | 02 |
| 2. As a customer, I want to remove an item… | 02, 04 |

Then read it both ways and report what you find:

- **Orphan stories** — a story no ticket delivers. Either a ticket is missing, or the story is out of scope and the spec should say so.
- **Orphan tickets** — a ticket delivering no story. That's scope nobody asked for; cut it, or the spec is incomplete.

This table is what turns spec conformance from a judgement call into something countable — `/spec-done` walks it as its first step, and each ticket PR cites the story numbers it satisfied. Building it now, while the breakdown is still editable, is also the cheapest coverage check available: a missing ticket costs nothing here and costs a whole gate later.

### 5. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work
- **Stories**: the user-story numbers it satisfies

Then show the traceability table and any orphans on either side.

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?
- Are the orphans right — is each uncovered story genuinely out of scope, and each unmapped ticket genuinely needed?

Iterate until the user approves the breakdown.

### 6. Publish the tickets to the configured tracker

Publish the approved tickets. **How** depends on the tracker `/setup-skills` configured — the tickets are the same either way, only the shape of the blocking edges changes:

- **Local files** → write one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). Each file's "Blocked by" lists the numbers/titles it depends on. Use the per-ticket file template below — one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, Linear, …)** → publish one issue per ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. Use the platform's native blocking / sub-issue relationship where it has one; otherwise set each ticket's "Blocked by" to the blocking issues. Apply the `ready-for-agent` triage label unless instructed otherwise — the tickets are agent-grabbable by construction.

### 7. Write the traceability table into the spec

The table lives in the **spec issue body** — one place, next to the stories it maps. Append it under a `## Traceability` heading, with real ticket references once they exist:

<traceability-section>

## Traceability

| Story | Ticket |
|---|---|
| 1 | #12 |
| 2 | #12, #14 |

Uncovered stories: none. / Stories 7, 9 — out of scope, see Out of Scope.

</traceability-section>

This is the **only** modification to make to the spec issue — it stays open, labels untouched, until its feature branch merges to the trunk, where `/cleanup` closes it. The same goes for any other parent issue: leave it as it is.

### 8. Working the tickets

Work the **frontier**: any ticket whose blockers have **merged into the feature branch**, which `/ticket-done` does as it closes each one. That merge is what makes the next ticket buildable — its task branch is cut from a feature branch that already contains the work beneath it. Nothing waits on the trunk; the feature branch merges there once, at the end, after `/spec-done`.

<local-ticket-template>

# <NN> — <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None — can start immediately".

**Stories:** the spec's user-story numbers this ticket satisfies.

**Status:** ready-for-agent

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</local-ticket-template>

<issue-template>

## Spec

A reference to the spec issue this ticket belongs to. **Always include this** — `/spec-done` needs every ticket to point back at its spec to walk the traceability table.

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not layer-by-layer implementation.

## User stories

The spec's numbered user stories this ticket satisfies.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- A reference to each blocking ticket, or "None — can start immediately".

</issue-template>

In either form, avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.
