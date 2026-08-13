# Agent Briefs

The brief is the contract an AFK agent works from; the issue body and discussion are only context.

## Principles

- **Durable over precise.** The issue may sit for weeks while the codebase moves. Describe interfaces, types, and behavioral contracts; never file paths or line numbers, never assumptions that the current structure survives.
- **Behavioral, not procedural.** What the system should do, not how to implement it — the agent explores fresh and makes its own implementation decisions. "The `SkillConfig` type should accept an optional `schedule` field", not "open src/types/skill.ts and add a field at line 42".
- **Checkable acceptance criteria.** Each criterion independently verifiable — "running `gh issue list --label needs-triage` returns classified issues", never "triage works correctly".
- **Explicit scope boundaries.** State what is out of scope, so the agent neither gold-plates nor wanders into adjacent features.

## Template

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** one line

**Current behavior:**
What happens now — the broken behavior, or the status quo the feature builds on.

**Desired behavior:**
What should happen when the work is done. Be specific about edge cases and errors.

**Key interfaces:**
- `TypeName` — what changes and why
- Config or API shapes the agent should look for or modify

**Acceptance criteria:**
- [ ] Specific, testable criterion

**Out of scope:**
- What must NOT be changed in this issue
```
