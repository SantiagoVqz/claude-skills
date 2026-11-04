# Ticket rules

Cut a spec into **tickets** with these rules. `spec` owns this file. Each ticket builds in one `/build` session, on one branch, as one PR. `issue` reads the `Lone ticket` section.

## Slices

Each ticket is a **vertical slice**: it goes through every layer that its stories touch, such as schema, API, UI and tests. A finished ticket is demoable or checkable on its own.

**One ticket by default.** Each ticket pays for its own session, branch and PR. Split only at a **boundary**:

| Boundary | Split when |
|---|---|
| Session | The work would not fit one session: an estimate over about 800 changed lines, tests included. Cut by stories, never by layers. |
| Schema | Tickets need one schema change. Put it in the first ticket that needs it, with the first behavior that uses it. |
| Prefactor | A change to the existing code keeps the behavior the same and makes the feature easier. It goes in its own early ticket. |
| Approval | The user asks to approve or ship a part on its own, such as a risky migration. |

A ticket with no boundary merges into its neighbor. Stories that repeat one pattern, such as three pages that each list records, stay in one ticket.

**Blocking edges.** Each ticket names the tickets that must merge before it starts, so a later ticket reads the code of the earlier one and reuses it. Two tickets gate each other when both add a migration, or both change one screen: put them in order.

**A wide refactor** is one mechanical change, such as a column rename, that breaks call sites across the whole codebase. Cut it as expand, migrate and contract: add the new form, move the call sites in batches, one ticket per batch, then remove the old form.

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

`Covers stories` names the user stories of the spec that the ticket makes work. Each story is in one ticket or more. The acceptance criteria tell when the ticket is done, and include the edge cases of its stories, such as an empty list or a value at its limit.

The ticket title goes in the issue title, or in the list item heading. Use the spec's words. Leave out file paths and code: they go stale before the work ends. The one exception is a prototype snippet that states a decision more exactly than prose. Trim it to the decision and say that it came from a prototype.

## Lone ticket

A **lone ticket** is a one-off change that has no parent spec. `/build` builds it on a `fix/<n>-<slug>` branch from the trunk.

- Use the template above without the `Covers stories` and `Boundary` lines.
- In "What to build", say what the user sees now and what the user sees after the change.
- Put related changes in one ticket.
