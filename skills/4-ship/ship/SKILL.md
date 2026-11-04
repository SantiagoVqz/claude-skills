---
name: ship
description: "Open the PR for a built branch: rebase on the trunk, check the hard stops, run one cold read of the whole diff, write the body, open the PR, and wait for CI to pass."
disable-model-invocation: true
argument-hint: "[issue]"
---

# Ship

`/ship` turns a built branch into one PR that the team can read. It runs the one cold read of the whole diff and the one full check of the code. It works on any branch with commits, with no earlier skill needed. It ends with the PR open, CI finished, and a short summary for the user. The merge is always the user's, with the method that step 1 finds.

In a worktree, follow the shell rules of the `build` skill.

## 1. Load

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, read `NO-SETUP.md` in the folder of the `setup-skills` skill, and go on with its sources.

The target is the argument, or the number in the current branch name. A branch with no number has no issue. Go to the worktree that has the branch, when one does. When `git status` shows changes, stop and ask whether they belong in this PR.

Find the **merge method**. Search `docs/adr/` for "merge commit", and read `gh repo view --json rebaseMergeAllowed,mergeCommitAllowed`. An ADR that needs merge commits wins. Otherwise use rebase and merge when the repo allows it, and a merge commit when it does not.

Completion: you have the branch, its issue when it has one, the trunk, as the `worktree` skill finds it, and the merge method.

## 2. Rebase

Run `git fetch origin`, then `git rebase origin/<trunk>`. On a conflict, call the Skill tool with `resolve-conflicts`.

Completion: the branch is on the latest trunk.

## 3. Hard stops

Run `hardstop-check.sh origin/<trunk>`, from the folder of this skill, in the root of the branch. It refuses a diff that holds a migration, a backfill, or auth or permission code when a commit says `Hard stops: none`.

When it refuses, show its lines, and ask with the question tool: "Override", with a reason that goes in the PR body, or "Stop".

Completion: the check passed, or the user gave the override reason.

## 4. Cold read

Start a subagent with a fresh context. Tell it to call the Skill tool with `verify`, with the issue, its criteria, and the diff `origin/<trunk>...HEAD`. Give it the shell rules, and no list of checks to skip. It needs only the conclusions, so keep the diff out of this context.

Fix each hard finding in this session, squash the fix into the commit, and run a new subagent. Run three cold reads or fewer. When a hard finding remains, stop and show it. The user fixes it, or overrides it with a reason that goes in the PR body. Judgment calls go in the report, and change nothing.

Completion: the last cold read has no hard finding, or the user gave each override reason.

## 5. Full checks

A workflow file is no proof that CI runs on this PR. Some repos have workflows that run only on `main` while the trunk is `develop`. Read the `on:` block of each file that `git ls-files .github/workflows` lists. **CI covers the PR** when a workflow has `pull_request` or `pull_request_target`, and its `branches` is missing or matches `<trunk>`, and its `branches-ignore` does not match `<trunk>`.

When CI covers the PR, skip the rest of this step. Otherwise start a subagent to run the full suite, the typecheck, the lint and the build, once, under the shell rules. Wait for its result, so that no check still runs when the user merges. When the repo has no script for a check, skip that check and name it in the report. A failure in the code of the branch stops `/ship`. Show its output.

Completion: CI covers the PR, or every check passed.

## 6. Write the body

Call the Skill tool with `pr` to write the body. Give it:

- **The title**: the title of the issue, or the subject of the commit.
- **The evidence**: the `<criterion> · <test>` lines of the commit message, the result of the cold read and each override reason. For a bug, the regression test.
- **The closing line**: `Closes #<n>`, or `Refs #<n>` for a bug whose cause is not confirmed. A branch with no issue has no closing line.
- **The merge line**: `Merge with <merge method>.`

Completion: you have the title and a body with each of these parts.

## 7. Open

Run `git push --force-with-lease origin <branch>`. Write the body to a file in the worktree root. Run `gh pr create --base <trunk> --head <branch> --title "<title>" --body-file <file>`. When the branch already has an open PR, run `gh pr edit <pr> --body-file <file>` in its place. Then delete the file.

Completion: the PR is open, ready for review, and `git status` is clean.

## 8. Watch CI

Skip this step when step 5 found that CI does not cover the PR.

Run `gh pr checks <pr> --watch` in the background, and wait for it to end. It can exit non-zero when every check passed, so read the result with `gh pr checks <pr>` each time it ends.

- **A check failed**: show the job name and the end of `gh run view <run> --log-failed`. Fix nothing, because the user decides how to fix it.
- **No check was reported**: CI did not start, for example because of a `paths` filter. Run the checks of step 5, and name the gap in the report.

Completion: each check passed, or you showed each failure, or the checks of step 5 ran because CI did not start.

## Report

Start with a short summary, three lines or fewer. Do not show the PR body.

```markdown
- <what changed> · because <why, from the issue's problem or the bug's cause>
```

Then: PR URL · hard-stop check · cold read result, with each judgment call · CI result, or `no CI on PRs to <trunk>` with where the checks ran · next step: merge with <merge method>, then `/cleanup`.
