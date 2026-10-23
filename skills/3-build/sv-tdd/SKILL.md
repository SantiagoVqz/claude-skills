---
name: sv-tdd
description: "Build a ticket test-first: red, green, one cycle per acceptance criterion, at the seams the spec agreed. Use when /sv-build runs an approach:tdd ticket, or the user wants to work red-green-refactor."
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

Read the ticket, its parent spec when it has one, the glossary that `docs/agents/domain.md` names, and the ADRs for the area. When the repo has no `docs/agents/domain.md`, find the glossary as `NO-SETUP.md` in the folder of the `sv-setup-skills` skill says. Look up in the glossary, and in its Avoid lists, each noun that you will use in a test, a component or a label, and each English word of the spec. Use the glossary words.

Find the **seams** in the spec's testing decisions. A seam is the public boundary where a test observes behavior. For a ticket with no parent spec, the agreed seams are the ones that the existing tests of the area use. Write tests only at these seams. When a criterion cannot be tested at an agreed seam, stop and ask the user. Propose the new seam in one line: what it catches and what it misses.

When the ticket asks for work that no criterion covers, such as a layout, name each piece in one line: `Build: <what>`.

Read the code in parts. Find the lines that a criterion names with `grep -n`, and read those lines with their function. Read a whole file only when it is the seam or its test file.

Completion: your message shows one line for each acceptance criterion, `<criterion> · <seam> · <test file>`, and one line for each `Build:` piece, before the first red. You looked up each noun and each English word in the glossary.

## 2. Loop

Take the acceptance criteria in order. For each criterion:

1. **Red**: write one test at the seam. Run it. It must fail, and the failure message must be about the missing behavior, not a typo or an import. When the ticket or the spec gives a literal, such as a label or a message, the test uses that literal. When you think the literal is wrong, ask the user before the green.
2. **Green**: write the least code that makes it pass. Add nothing for a later criterion.
3. **Commit**: `Green: <criterion>`.

When a new test passes on its first run, it proves nothing yet. Do one of these, and name it in the commit message:

- Take a later criterion first, when that criterion makes this test fail.
- Break a committed file for one run, see the test fail, and undo the break with `git checkout -- <file>`.

A criterion that sets a rule for the tests, such as how each test sets the clock, gets no cycle. The report names the tests that follow it.

A criterion that keeps existing behavior, such as "marks still work", gets no cycle when existing tests cover it. The report names those tests. Run them after the last change. When this ticket changed those tests, say so in the report.

A criterion can take more than one cycle. Each cycle gets its own commit. Run the test file in each cycle, and the typecheck in each cycle that changes source.

After the last cycle, build each `Build:` piece from step 1 in its own commit: `Build: <what>`. Change only what the piece names.

Completion: each acceptance criterion has a passing test and a `Green:` commit, or names the existing tests that cover it, and each `Build:` piece has its commit.

## 3. Refactor

Read `git diff <base>...HEAD` in full. Under `/sv-build`, the base is the base that `/sv-build` names: the spec branch, or the trunk for a lone ticket. Then look for the duplication that a read of the diff alone does not show:

- For each new helper, search the codebase for one that does the same job.
- Compare the new code with the code of the earlier tickets of the same spec, when the ticket has a spec.
- List each place that branches on the new case. Several checks that decide one case are one decision.

Remove duplication, fix names, and move code to where it belongs. Commit each change: `Refactor: <what>`. Run the test files of each change after it. Formatting is the linter's job, so a format change is no refactor.

Then run the repo's formatter and lint on the diff, and commit any change: `Format: <files>`. Then run the full suite once, and wait for its result.

Completion: the formatter and lint pass, the full suite passed after the last change, and that run has finished. A run in the background counts only when its result is in. You have no more changes to make.

## Good tests

A good test checks behavior through a public interface. It reads like a line of the spec, and it survives a refactor. See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for when to mock.

- **Implementation-coupled**: the test mocks an internal module, tests a private function, or checks through a side door, such as a database query in place of the interface. It breaks on a refactor that keeps the behavior.
- **Tautological**: the expected value is computed the way the code computes it, so the test cannot fail. Take expected values from a known literal, a worked example or the spec.
- **Horizontal**: all tests first, then all code. The tests then check an imagined design. Write one test, then its code.

## Excuses

| Excuse | Answer |
|---|---|
| "The code reads clean, so no refactor is needed." | Name the diff that you read and the helpers that you searched for. |
| "The rest of the code writes the literal another way." | The spec is the contract. Ask the user before the green. |
| "I know the seams, so the list can wait." | Print the seam list before the first red. The user and verify read it. |

Add a row only when `/sv-retro` finds a new excuse.

## Report

Print the report in your message before you return to the caller:

- Each acceptance criterion with its test name, or with the existing tests that cover it.
- Each `Build:` piece.
- The commits.
- Each seam question and each literal question that the user answered.
