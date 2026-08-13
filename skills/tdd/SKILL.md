---
name: tdd
description: Test-driven development. Use when building features or fixing bugs test-first, or the user mentions "red-green-refactor" or integration tests.
---

# TDD

TDD is the red → green loop. This reference makes the loop produce tests worth keeping; every section applies on every cycle, before and during — not after.

When exploring, read `CONTEXT.md` (if it exists) so test names and interface vocabulary match the domain language, and respect ADRs in the area.

## What a good test is

Tests verify behavior through public interfaces, never implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification — "user can checkout with valid cart" says exactly what capability exists — and survives refactors because it doesn't care about internal structure. See [tests.md](tests.md) for examples and mocking rules.

## Seams — where tests go

A **seam** is the public boundary you test at: where behavior is observable without reaching inside. **Test only at pre-agreed seams.** Before any test, write down the seams under test and confirm them with the user — that agreement is how testing effort lands on critical paths instead of every edge case. Ask: "What's the public interface, and which seams should we test?"

## Anti-patterns

- **Implementation-coupled** — mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of the interface). The tell: the test breaks on refactor though behavior didn't change.
- **Tautological** — the assertion recomputes the expected value the way the code does, so it passes by construction. Expected values come from an independent source of truth: a known-good literal, a worked example, the spec.
- **Horizontal slicing** — all tests first, then all implementation. Bulk tests verify *imagined* behavior. Work in vertical slices: one test → one implementation → repeat, each test a **tracer bullet** responding to what the last cycle taught you.

## Rules of the loop

- **Red before green.** The failing test first, then only enough code to pass it — no speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactoring is not part of the loop.** It belongs to review, not the red → green cycle.
