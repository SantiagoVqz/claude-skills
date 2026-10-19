# Ticket rules

Cut a PRD or spec into **tickets** with these rules. `/sv-prd` owns this file. `/sv-plan` reads it too, and adds its own labels on top.

## Slices

Each ticket is a **tracer bullet**: a narrow vertical slice through every layer that the feature touches, such as schema, API, UI and tests. A finished ticket is demoable or checkable on its own.

- **Prefactor first.** When a change to the existing code makes the feature easier, put that change in its own early ticket. Make the change easy, then make the easy change.
- **Schema first.** Put all schema changes in one early ticket. Every ticket that needs the new schema is blocked by it. Read the PRD's `Schema changes` line to find them.
- **Size.** One ticket fits in one context window and one git worktree. Size the tickets so several can run in parallel on one laptop. A ticket that is too small adds more overhead than work, so merge it with its neighbor.
- **Blocking edges.** Each ticket names the tickets that must finish before it can start. Name only a ticket that truly gates it. A ticket with no blockers can start at once.

## Wide refactors

A wide refactor is one mechanical change, such as a column rename, that breaks call sites across the whole codebase. No vertical slice can stay green through it. Use **expand, migrate, contract**:

1. **Expand**: add the new form next to the old form. Nothing breaks.
2. **Migrate**: move the call sites in batches, one ticket per batch, such as one package or one folder. Each batch is blocked by the expand ticket.
3. **Contract**: remove the old form, in a ticket blocked by every batch.

## Template

```markdown
## What to build

The end-to-end behavior that this ticket makes work, from the user's point of view.

Covers stories: 1, 2

## Blocked by

- Each blocking ticket, or "None, can start at once".

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
```

`Covers stories` names the user stories of the PRD that the ticket makes work. Each story is in one ticket or more. The acceptance criteria tell when the ticket is done.

The ticket title goes in the issue title, or in the list item heading. Use the PRD's words. Leave out file paths and code: they go stale before the work ends. The one exception is a prototype snippet that states a decision more exactly than prose. Trim it to the decision and say that it came from a prototype.
