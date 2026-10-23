# Plan rules

A **plan** is the ordered **phases** that `/sv-build` builds in one run. `/sv-build` drafts it when a spec has no plan comment. `sv-issue`, `sv-review` and `TICKETS.md` read the approach table below.

## Cut

Cut the spec's stories into phases. **One phase by default.** Each phase pays a fixed cost: an implementer subagent, the verify runs and a commit. Split only at a **boundary**:

| Boundary | Split when |
|---|---|
| Prefactor | A change to the existing code keeps the behavior the same and makes the feature easier. It goes in its own first phase with `approach:refactor`. Make the change easy, then make the easy change. |
| Context | The work would not fit in one implementer's context: more than about 1500 changed lines. Count added and deleted lines, tests included, and estimate from the files that the stories touch. |

Each phase is a **vertical slice**: it goes through every layer that its stories touch, such as schema, API, UI and tests. At a context boundary, cut by stories, not by layers. The first phase that needs a schema change takes all of it, with the first behavior that uses it. Read the spec's `Schema changes` line to find the changes.

A **wide refactor** is one mechanical change, such as a column rename, that breaks call sites across the codebase. Plan it as phases: expand, with the new form next to the old one; one phase per batch of call sites; then contract, which removes the old form.

Each story is in one phase or more. When a story fits no phase, ask the user whether it is out of scope.

## Approach

Give each phase one approach. `/sv-build` runs `sv-` plus the approach, such as `sv-tdd`. Tasks use the same values as labels:

| Approach | When |
|---|---|
| `approach:tdd` | The work adds or changes behavior. |
| `approach:refactor` | The behavior stays the same: a prefactor, or a batch of a wide refactor. |
| `approach:diagnose` | The work starts from a defect whose cause is unknown. |

## Criteria

Write the done-when criteria of each phase. They tell when the phase is done, and include the edge cases of its stories, such as an empty list or a value at its limit. Use the spec's words. Leave out file paths and code: they go stale before the work ends.

## Format

The plan comment on the spec issue:

```markdown
### Plan of #<spec>

#### Phase 1: <title>
<approach> · stories 1, 2 · boundary: <the boundary, or "one phase">

Builds: <one sentence, from the user's point of view>
Done when:
- <each criterion>

#### Phase 2: <title>
...
```
