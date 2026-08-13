# ADR Format

ADRs live in `docs/adr/`, numbered sequentially: `0001-slug.md`, `0002-slug.md`. Scan for the highest number and increment. Create the directory lazily when the first ADR is needed.

## Template

```md
# {Short title of the decision}

{1-3 sentences: the context, what we decided, and why.}
```

An ADR can be a single paragraph — the value is recording *that* a decision was made and *why*. Add sections only when they earn it: `Status` frontmatter when decisions get revisited, **Considered Options** when the rejected alternatives are worth remembering, **Consequences** when downstream effects are non-obvious.

## What qualifies

All three gates must hold — hard to reverse, surprising without context, a real trade-off. Typical qualifiers:

- **Architectural shape** — "the write model is event-sourced, the read model projected into Postgres."
- **Integration patterns between contexts** — "Ordering and Billing communicate via domain events, not synchronous HTTP."
- **Technology choices with lock-in** — database, message bus, auth provider; not every library.
- **Boundary decisions** — "Customer data is owned by the Customer context; others reference by ID only."
- **Deliberate deviations from the obvious path** — stops the next engineer from "fixing" something deliberate.
- **Constraints invisible in the code** — compliance limits, partner-contract latency budgets.
- **Non-obvious rejections** — record why GraphQL lost to REST, or someone re-proposes it in six months.
