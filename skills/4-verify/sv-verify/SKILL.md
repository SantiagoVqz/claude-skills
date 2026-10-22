---
name: sv-verify
description: "Review a diff against its ticket and the repo's standards, and report hard findings and judgment calls. Use when /sv-build or /sv-diagnose asks for a verify run, or the user asks to verify a diff."
argument-hint: "[ticket] [ref]"
metadata:
  credits:
    skill: code-review
    author: Matt Pocock
    organisation: AI Hero
    url: "https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md"
---

# Verify

`/sv-verify` is the adversarial review of one diff. It reports and edits nothing. The caller fixes the findings.

A finding is **hard** or a **judgment call**. A hard finding blocks the ticket. A judgment call goes to the user.

## 1. Pin the diff

Use the diff and the ticket that the caller gave. When you run on your own:

- **Ticket**: the argument, or the number in a `ticket/<n>-` or `fix/<n>-` branch name.
- **Base**: the ref. With no ref, use the spec branch for a ticket branch. For any other branch, use `git merge-base origin/<trunk> HEAD`, because a local trunk can be ahead of the branch base.
- **Diff**: `git diff <base>`. It includes the work that is not committed yet.

Read the ticket with its acceptance criteria, and its parent spec with the testing decisions. Run `git diff --stat <base>` and `git status --short`. Read each untracked file: `git diff` does not show it.

Completion: the base resolves, the diff is not empty, you have the acceptance criteria, and you know each untracked file.

## 2. Run the checks

Find the test, typecheck, lint and build commands in `package.json`, the README or `AGENTS.md`. Run the typecheck, the lint and the build. Run the test files that the diff adds or changes, and each test file that imports a module that the diff changes. Run the full suite when the caller asks for it, or when you run on your own. `/sv-build` runs the full suite after its rebase, so each verify round skips it. Trust no earlier report.

Completion: each check passed or failed, each run has finished, and you have the output of each failure.

## 3. Review

Read the diff once for each heading. Keep the two headings apart, so that one does not hide the other.

**Spec**: does the diff do what the ticket asks?

- Each acceptance criterion has code and a test that proves it.
- Each test is at a seam from the spec's testing decisions.
- Each expected value comes from a literal, a worked example or the spec, not from the code's own logic.
- The result can be checked from outside: through the UI, an API or a command. A ticket that changes one layer only, such as storage with no UI, is not a vertical slice.
- Behavior that the ticket did not ask for is a judgment call.

For an `approach:refactor` ticket, the behavior must stay the same. Replace the first item and the vertical slice item with these: no expected value in an existing test changed, each test change follows a rename or a move, and each acceptance criterion is met in the structure of the code.

**Standards**: does the diff follow the rules of the repo?

- Find the written rules: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `CODING_STANDARDS.md` and the ADRs for the area.
- Then read `SMELLS.md` in the folder of this skill with the Read tool, and look for its smells. A written rule wins over a smell.
- Skip what a linter or a formatter already enforces.

Completion: each criterion, each test and each written rule is checked, and you read each changed or new test file.

## 4. Sort

A finding is hard when it is one of these:

- A check from step 2 fails.
- An acceptance criterion has no code, or no test proves it.
- A test is at a seam that the spec did not agree, or it is tautological.
- The diff breaks a written rule of the repo.
- The ticket is not a vertical slice. This does not apply to a refactor ticket.
- A refactor ticket changed an expected value in an existing test.

Everything else is a judgment call. Keep the five that matter most.

Completion: each finding is hard or a judgment call, and you have five judgment calls or fewer.

## Excuses

| Excuse | Answer |
|---|---|
| "A test of a class name is tautological, and I checked it in the browser." | Report the criterion as hard, with the browser evidence. The user decides. |
| "The code diff reads clean." | Read each changed and new test file before you call the diff clean. |
| "Check and lint passed earlier in this session." | Run each check again in this verify run. Edits since then can break it. |

Add a row only when `/sv-retro` finds a new excuse.

## Report

```markdown
## Hard
- <file>:<line> · <rule or criterion> · <what is wrong>

## Judgment calls
- <file>:<line> · <smell> · <fix in a few words>
and <n> more
```

Print this block in each run, before the caller commits. Write "None" under a heading that has no findings. Write each finding on one line. Leave out the "and <n> more" line when you kept every judgment call.
