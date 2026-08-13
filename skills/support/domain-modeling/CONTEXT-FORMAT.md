# CONTEXT.md Format

`CONTEXT.md` is the project glossary — the ubiquitous language. One at the repo root for most repos.

```md
# {Context Name}

{One or two sentences: what this context is and why it exists.}

## Language

**Order**:
{One or two sentence definition — what it IS, not what it does.}
_Avoid_: Purchase, transaction

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** When multiple words exist for one concept, pick the best and list the rest under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max.
- **Only project-specific terms.** General programming concepts (timeouts, error types, utility patterns) never belong, however heavily used.
- **Group under subheadings** only when natural clusters emerge; a flat list is fine.

## Multi-context repos

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts; the map lists where each `CONTEXT.md` lives and how contexts relate (events consumed, shared types). Infer which context the current topic belongs to; ask if unclear. If neither file exists, create a root `CONTEXT.md` lazily when the first term resolves.
