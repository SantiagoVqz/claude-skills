# Spec template

Write the spec or PRD body with this template. Use the words that the repo already uses, from its glossary when it has one. Leave out file paths and code: they go stale before the work ends. The one exception is a prototype snippet that states a decision more exactly than prose, such as a state machine or a type shape. Trim it to the decision and say that it came from a prototype.

```markdown
## Problem

The problem, from the user's point of view.

## Solution

The solution, from the user's point of view.

## User stories

1. As a <actor>, I want <capability>, so that <benefit>.
2. ...

## Implementation decisions

- The modules to build or change, and their interfaces.
- Data shapes, API contracts and architectural decisions.
- Prototype verdicts, each with the question it settled.

Schema changes: <each migration, or none>

## Testing decisions

- The seams to test at, and the behavior each seam proves.
- Prior art: tests in the codebase to copy the shape of.

## Out of scope

- Each thing this spec does not do.

## Domain changes

- Term: **<term>**: <its definition>. _Avoid_: <other words>
- ADR: <short title>: <the context, the decision and the reason>.

## Notes

Anything else a builder needs. Delete this section when it is empty.
```

## Rules

- **User stories**: one story per main behavior that a user can see. Each story must describe something that a person can do and check, because the work is accepted story by story. In a repo with the full flow, `/sv-review` proves each story at runtime. Cover the whole feature with the fewest stories that do it. An edge case goes in the criteria of the phase or ticket that covers its story.
- **Schema changes**: the line is always present. `/sv-build` puts all migrations in the first phase that needs them, and `/sv-prd` in one early ticket.
- **Domain changes**: the terms and ADR candidates of the confirmed decisions log, and nothing else. `/sv-build` writes them to the glossary and `docs/adr/` in its first commit. A PRD and a spec with none leave the section out.
- **Testing decisions**: test external behavior only. Prefer an existing seam to a new one, and the highest seam to a lower one. The best number of seams is one.
