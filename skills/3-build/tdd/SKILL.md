---
name: tdd
description: "Build a ticket test-first: red, green, one cycle per acceptance criterion, at the seams the spec agreed. Use when /build runs an approach:tdd ticket, or the user wants to work red-green-refactor."
metadata:
  credits:
    skill: tdd
    author: Matt Pocock
    organisation: AI Hero
    url: "https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md"
---

# TDD

TDD is the red, green loop. Each cycle is a **tracer bullet**: one failing test, then the least code that makes it pass. The ticket's acceptance criteria are the list of cycles.

## 1. Prepare

Read the ticket, its parent spec, `GLOSSARY.md` and the ADRs for the area. Use the glossary words in test names.

Find the **seams** in the spec's testing decisions. A seam is the public boundary where a test observes behavior. Write tests only at these seams. When a criterion cannot be tested at an agreed seam, stop and ask the user. Propose the new seam in one line: what it catches and what it misses.

Completion: you can name the seam for each acceptance criterion.

## 2. Loop

Take the acceptance criteria in order. For each criterion:

1. **Red**: write one test at the seam. Run it. It must fail, and the failure message must be about the missing behavior, not a typo or an import.
2. **Green**: write the least code that makes it pass. Add nothing for a later criterion.
3. **Commit**: `Green: <criterion>`.

When a new test passes on its first run, it proves nothing yet. Do one of these, and name it in the commit message:

- Take a later criterion first, when that criterion makes this test fail.
- Break the code for one run, see the test fail, and undo the break. Confirm that `git diff` shows no source change before the next break.

A criterion that sets a rule for the tests, such as how each test sets the clock, gets no cycle. The report names the tests that follow it.

A criterion can take more than one cycle. Each cycle gets its own commit. Run the typecheck and the test file each cycle.

Completion: each acceptance criterion has a passing test and a `Green:` commit.

## 3. Refactor

Read all the code that the ticket added. Remove duplication, fix names, and move code to where it belongs. Run the full suite after each change, and keep it green. Commit each change: `Refactor: <what>`.

Completion: the full suite passes, and you have no more changes to make.

## Good tests

A good test checks behavior through a public interface. It reads like a line of the spec, and it survives a refactor. See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for when to mock.

- **Implementation-coupled**: the test mocks an internal module, tests a private function, or checks through a side door, such as a database query in place of the interface. It breaks on a refactor that keeps the behavior.
- **Tautological**: the expected value is computed the way the code computes it, so the test cannot fail. Take expected values from a known literal, a worked example or the spec.
- **Horizontal**: all tests first, then all code. The tests then check an imagined design. Write one test, then its code.

## Excuses

| Excuse | Answer |
|---|---|

No rows yet. Add a row only when `/retro` finds a new excuse.

## Report

Each acceptance criterion with its test name · the commits · each seam question that the user answered.
