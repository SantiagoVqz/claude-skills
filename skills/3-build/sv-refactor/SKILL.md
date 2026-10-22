---
name: sv-refactor
description: "Change the structure of code and keep its behavior, in small steps with the suite green after each one. Use when /sv-build runs an approach:refactor ticket, or the user asks for a refactor."
metadata:
  credits:
    skill: code-simplification
    author: Addy Osmani
    organisation: agent-skills
    url: "https://github.com/addyosmani/agent-skills/blob/main/skills/code-simplification/SKILL.md"
---

# Refactor

A refactor changes the structure and keeps the behavior. The suite is the proof: it is green before the first step and after each step. The ticket's acceptance criteria say what the structure is at the end, such as "the streak logic is one module" or "no caller imports `db/raw`".

## 1. Prepare

Read the ticket, its parent spec, the glossary that `docs/agents/domain.md` names, and the ADRs for the area. When the repo has no `docs/agents/domain.md`, find the glossary as `NO-SETUP.md` in the folder of the `sv-setup-skills` skill says. Use the glossary words in new names.

Read the code that the ticket changes, with its callers. For each piece that you plan to remove or merge, find why it exists: read `git log -L` or `git blame` for it. This is **Chesterton's fence**: when you cannot say why a piece exists, keep it, and ask the user.

Completion: you can name each piece that the ticket changes, and why each piece that you remove exists.

## 2. Pin the behavior

Run the full suite and the typecheck. Both must pass before the first change.

For each behavior that the refactor touches, find a test at a seam from the spec that proves it. When a behavior has no test, write a **pin test** at an agreed seam: it asserts what the code does now, odd parts included. It passes on its first run. Then break the code for one run, see the test fail, and undo the break. Commit each pin test: `Pin: <behavior>`.

When a behavior can be tested only at a new seam, stop and ask the user. Propose the seam in one line: what it catches and what it misses.

Completion: each behavior that the refactor touches has a passing test at an agreed seam.

## 3. Step

Change the structure in small steps. Each step is one named refactoring, such as Rename, Extract Function, Inline Function, Move Function, Introduce Parameter Object or Replace Conditional with Map. After each step, run the typecheck and the suite.

- **Green**: commit `Refactor: <refactoring>: <what>`.
- **Red**: undo the step with `git checkout -- .` and take a smaller step. Do not fix forward.

A test can change only with the structure: an import path, or a name that the step renamed. An expected value never changes. When an expected value seems wrong, the behavior changed: undo the step.

For a refactor too wide for one ticket, use **parallel change**: one ticket adds the new structure, the next tickets move the callers in batches, and the last ticket removes the old structure. Each ticket leaves the app working.

Completion: each acceptance criterion is met, and the suite is green.

## 4. Check

Run `git diff <spec-branch>...HEAD` on the test files. Confirm that no expected value changed, and that each test change follows a rename or a move. Read all the changed code once more: each new name says what the thing does, and no piece is left that only passes calls on.

Completion: no expected value changed, the full suite is green, and you have no more steps to make.

## Balance

Clarity is the goal, not fewer lines. Keep a helper that gives a concept a name. Keep two simple functions apart, rather than one complex function. Change only what the ticket names.

## Excuses

| Excuse | Answer |
|---|---|

No rows yet. Add a row only when `/sv-retro` finds a new excuse.

## Report

Each acceptance criterion with how it is met · the pin tests · the refactor commits · each test change and the step that caused it · each seam question that the user answered.
