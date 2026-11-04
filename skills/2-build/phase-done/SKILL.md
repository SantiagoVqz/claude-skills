---
name: phase-done
description: "Close a phase of built work: simplify the diff, run the scoped checks, compare the scope with the plan, commit, and report. Use when /build ends a phase, or the user says that a phase is done."
argument-hint: "[phase base]"
---

# Phase done

`/phase-done` closes one phase. A ticket with no phases is one phase. It asks nothing between steps, and it ends with one commit for the phase.

The **phase base** is the start that the caller gives. With none, use `git merge-base origin/<trunk> HEAD`. Find the trunk as the `worktree` skill does.

In a worktree, follow the shell rules of the `build` skill.

**Delegated work.** The implementer runs steps 1 and 2, because it already holds the diff. It returns the simplify note, and the last line and the exit status of each check. Send a report without them back to the same implementer with `SendMessage`, and name what is missing. Then start at step 3. Run a check again only when step 3 or step 4 changes the code.

## 1. Simplify

Read `git diff <phase base>` and each untracked file. Find what to cut: code that the work no longer needs, an old pattern kept as a fallback next to its replacement, a helper with one caller, a parameter or a branch that no criterion asks for. After `tdd` or `refactor`, duplication and names are already done, so look only for cuts.

The best result of a finding is less code. Keep each trust-boundary check, each caveat, and each test that proves a criterion. A cut keeps the behavior. In a change round after the report, look only at the change.

Completion: you have the note `Simplify: <what you cut, and the lines>`, or `Simplify: nothing to cut`.

## 2. Check

Run the typecheck, the lint, and the tests that the diff adds or touches. A run counts when it finished after the last edit, so a run from `tdd` can stand when step 1 changed nothing. Leave the full suite to `/ship`. A failure is yours to fix now.

Completion: each check passed after the last edit, and you have its last line and exit status.

## 3. Scope

Run `git diff --stat <phase base>` and `git status --short`, and compare them with the plan. Look for a file that the plan does not touch, a line count far from the shape of the plan, and a user-visible element that the plan does not name. Read the diff where the stat looks wrong.

Remove what the plan did not ask for, and run step 2 again on the result. A change that the work needs stays, and goes in the report with its reason. A hard stop that the plan does not name goes to the question in step 5 of `build`.

Completion: each changed file belongs to the plan, or the report names it with its reason.

## 4. Cold read

Run this step only for the first close of a phase of a multi-file migration or refactor. Other phases wait for the one cold read at `/ship`, and the report says "cold read: at /ship".

Start a subagent with a fresh context. Tell it to call the Skill tool with `verify`, with the criteria of the phase and the phase base as the ref. Give it the shell rules. Fix each hard finding, and run step 2 again. Judgment calls go in the report.

Completion: the cold read has no hard finding, or this phase needs no cold read.

## 5. Commit

Stage the files of the phase. Run `git reset --soft <phase base>`, and make one commit, with one `-m` flag per paragraph:

- `<title> (#<n>)`. In a plan with phases: `<title>: <phase title> (#<n>)`.
- one line for each criterion of the phase: `<criterion> · <test name, or what you saw>`
- `Hard stops: <the verdict>`, in the last paragraph, so that `/ship` can read it as a trailer. Any `Co-Authored-By` line goes right below it.

Work that `NO-SETUP.md`, in the folder of the `setup-skills` skill, keeps uncommitted skips this step.

Completion: the phase has one commit over its base and `git status` is clean, or the work stays uncommitted as `NO-SETUP.md` says.

## Report

What the phase delivered · the simplify note · the last line of each check · the commit · each change outside the plan · the cold read result, or "cold read: at /ship".
