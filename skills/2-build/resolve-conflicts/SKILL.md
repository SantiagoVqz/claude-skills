---
name: resolve-conflicts
description: "Resolve a git merge or rebase conflict that is in progress, and keep the intent of both sides. Use when a rebase or merge stops on a conflict."
metadata:
  credits:
    skill: resolving-merge-conflicts
    author: Matt Pocock
    organisation: AI Hero
    url: "https://github.com/mattpocock/skills/blob/c55ee46/skills/engineering/resolving-merge-conflicts/SKILL.md"
---

# Resolve conflicts

A conflict has two **intents**, one for each side. Each side was made for a reason, and the resolution keeps both reasons.

## 1. See the state

Run `git status` to get the conflicted files, and to see whether a rebase or a merge is in progress. Read the commits of each side with `git log`.

Completion: you know each conflicted file and the commits on each side.

## 2. Find the intents

For each side, read its commit messages and the ticket or issue that they name, with its acceptance criteria. Write each intent in one sentence.

Completion: each conflict has two intents, one sentence each.

## 3. Resolve

Resolve each hunk so that both intents work. Add no behavior that neither side asked for. When the code of one side replaces the code of the other side, keep each check and each error that the replaced code had.

When both sides change the same behavior in different ways, both intents cannot work. Do not pick one. Ask the user with the question tool, with one option for each side. Each option shows its intent and its ticket in one line.

Completion: no file has conflict markers, and each hunk keeps both intents or follows the user's choice.

## 4. Check

Run the checks of the repo: the typecheck, the tests, the lint and the build. Fix what the resolution broke.

Completion: every check passes.

## 5. Finish

Stage the files and continue: `git rebase --continue`, or commit the merge. Continue until the rebase has applied every commit. Each new conflict starts again at step 1.

Completion: `git status` shows no rebase and no merge in progress.

## Report

Each conflicted file · the two intents · how you resolved it · the user's choices.
