---
name: tickets
description: Cut a spec or plan into strictly vertical tracer-bullet tickets with blocking edges, sized for parallel worktree agents.
disable-model-invocation: true
---

# Tickets

Break a spec, plan, or the current conversation into **tracer-bullet tickets** — strictly vertical slices, each declaring the tickets that **block** it. The tickets are built for parallel execution: any ticket whose blockers are all done (the **frontier**) can be picked up by an agent in its own worktree, implemented, and merged to trunk on its own.

## Process

### 1. Gather

Work from the conversation context. If the user passes a spec path or issue number, fetch and read it fully.

### 2. Explore

If you haven't explored the codebase, do so. Use the glossary vocabulary from `CONTEXT.md`; respect ADRs in the area. Look for **prefactoring** opportunities — "make the change easy, then make the easy change" — and put any prefactor first as its own ticket.

### 3. Draft the slices

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer it touches — schema, API, UI, tests together in one ticket. A backend change and its frontend consumer ship in the same slice, never as separate half-features.
- A completed slice is demoable or verifiable on its own, so it can land on trunk by itself.
- Each slice fits one fresh context window.
- Prefactoring comes first.

</vertical-slice-rules>

Give each ticket its **blocking edges** — the tickets that must complete before it starts. Two kinds of edge:

- **Logical** — the slice genuinely builds on the other's behavior.
- **Same code area** — two frontier tickets that would edit the same files in parallel worktrees will collide at merge; sequence them with an edge even when logically independent.

**Wide refactors are the exception to vertical slicing.** When one mechanical change (rename a column, retype a shared symbol) has a blast radius no single slice can land green, sequence it as **expand–contract**: an expand ticket adds the new form beside the old; migrate tickets move call sites over in batches (per package or directory), each blocked by the expand, CI green throughout because the old form survives; a contract ticket deletes the old form, blocked by every migrate batch.

### 4. Quiz the user

Present the breakdown as a numbered list — title, blocked-by, and what end-to-end behaviour it delivers. Ask: granularity right? edges correct and minimal? anything to merge or split? Iterate until approved.

### 5. Publish

Publish one issue per ticket in dependency order (blockers first) to the repo's tracker (GitHub via `gh` by default), using native blocking relationships where they exist, otherwise a "Blocked by" list in the body. Label each `ready-for-agent`. No tracker → one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered in dependency order. Never close or modify a parent issue.

<ticket-template>

## Parent

Reference to the parent spec/issue, if any.

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer list.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

References to each blocking ticket, or "None — can start immediately".

</ticket-template>

No file paths or code snippets in tickets — they go stale. Exception: a prototype-derived snippet that encodes a decision more precisely than prose, trimmed to the decision-rich parts.
