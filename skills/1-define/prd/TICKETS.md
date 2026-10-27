# Ticket rules

Cut a PRD into **tickets** with these rules. `/prd` owns this file. A spec gets phases from `/build`, not tickets. `issue` and `final-review` read the `Lone ticket` section.

## Slices

Each ticket is a **vertical slice**: it goes through every layer that its stories touch, such as schema, API, UI and tests. A finished ticket is demoable or checkable on its own.

**One ticket by default.** Each ticket pays a fixed cost: its own branch, its own review and its own context. Code in two tickets is written in two contexts, so the second ticket copies the first. Cut the whole PRD as one ticket. Split it only at a **boundary**:

| Boundary | Split when |
|---|---|
| Parallel | Two parts share no files, neither needs the other, and the user plans to build them at the same time. Ask the user when you do not know. |
| Schema | Two or more parallel tickets need the same schema change. Put the change in one early ticket that blocks them, with the first behavior that uses it, so that ticket is a vertical slice too. Read the PRD's `Schema changes` line to find the changes. |
| Prefactor | A change to the existing code keeps the behavior the same and makes the feature easier. It goes in its own early ticket with `approach:refactor`. Make the change easy, then make the easy change. |
| Context | The work would not fit in one context window: more than about 1500 changed lines. Count added and deleted lines, tests included, and estimate from the files that the stories touch. |
| Approval | The user asks to approve or ship a part on its own, such as a risky migration. Use it only when the user asks. |

Each ticket in a split names the boundary that separates it. A ticket with no boundary merges into its neighbor. Story count and line count below the context boundary are not boundaries: stories that repeat one pattern, such as three pages that each list records, stay in one ticket.

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
Boundary: <the boundary that separates this ticket, or "one ticket">

## Blocked by

- Each blocking ticket, or "None, can start at once".

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
```

`Covers stories` names the user stories of the PRD that the ticket makes work. Each story is in one ticket or more. The acceptance criteria tell when the ticket is done, and include the edge cases of its stories, such as an empty list or a value at its limit.

The ticket title goes in the issue title, or in the list item heading. Use the PRD's words. Leave out file paths and code: they go stale before the work ends. The one exception is a prototype snippet that states a decision more exactly than prose. Trim it to the decision and say that it came from a prototype.

## Lone ticket

A **lone ticket** is a one-off change that has no parent spec. `/build` builds it on a `fix/<n>-<slug>` branch from the trunk, and `/ship` opens its PR.

- Use the template above without the `Covers stories` and `Boundary` lines.
- In "What to build", say what the user sees now and what the user sees after the change.
- Give it one approach label from the table in `PLAN.md`, in the folder of the `build` skill.
- Put related changes in one ticket, by the one-ticket rule above.
