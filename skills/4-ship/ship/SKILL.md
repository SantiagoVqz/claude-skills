---
name: ship
description: "Open the PR for a built branch: rebase on the trunk, check the hard stops, push a draft PR, run one cold read of the whole diff while CI runs, write the body, and mark the PR ready."
disable-model-invocation: true
argument-hint: "[issue]"
---

# Ship

`/ship` turns a built branch into one PR that the team can read. It pushes a draft first, so that CI is the one full check of the code and the cold read runs next to it. It works on any branch with commits, with no earlier skill needed. It ends with the PR open, CI finished, and a short summary for the user. The merge is always the user's, with the method that step 1 finds.

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

## 4. Find CI

A workflow file is no proof that CI runs on this PR. Some repos have workflows that run only on `main` while the trunk is `develop`. Read the `on:` block of each file that `git ls-files .github/workflows` lists. **CI covers the PR** when a workflow has `pull_request` or `pull_request_target`, and its `branches` is missing or matches `<trunk>`, and its `branches-ignore` does not match `<trunk>`. In those workflows, list which of the typecheck, the lint, the build and the tests run.

**CI skips drafts** when a covering workflow has a `types` list with no `opened` or `synchronize`, or a job with an `if` on `draft`.

Completion: you know whether CI covers the PR, which checks it runs, and whether it skips drafts.

## 5. Open a draft

Run `git push --force-with-lease origin <branch>`. When the branch has no open PR, write a short body to a file in the worktree root, with the closing line and the merge line of step 8. Run `gh pr create --draft --base <trunk> --head <branch> --title "<title>" --body-file <file>`. When CI skips drafts, or GitHub refuses a draft on this repo, run the command with no `--draft`. Then delete the file. When CI covers the PR, run `gh pr checks <pr> --watch` in the background.

Completion: the PR is open with the latest commit, and the watch runs when CI covers the PR.

## 6. Cold read

Start a subagent with a fresh context. Tell it to call the Skill tool with `verify`, with the issue, its criteria, the diff `origin/<trunk>...HEAD`, and the checks that CI runs. Give it the shell rules. It needs only the conclusions, so keep the diff out of this context.

Fix each hard finding in this session, squash the fix into the last commit, push as in step 5, start a new watch, and run a new subagent. Run three cold reads or fewer. When a hard finding remains, stop and show it with the PR URL. The user fixes it, and you push and run one more cold read, or the user overrides it with a reason that goes in the PR body. Judgment calls go in the report, and change nothing.

Completion: the last cold read has no hard finding, or the user gave each override reason.

## 7. Full checks

Skip this step when CI runs the tests. Otherwise start a subagent to run the full suite once, under the shell rules. The last cold read already ran each other check that CI does not run. Wait for its result, so that no check still runs when the user merges. When the repo has no script for a check, skip that check and name it in the report. A failure in the code of the branch stops `/ship`. Show its output.

Completion: CI runs the tests, or the full suite passed.

## 8. Write the body

Call the Skill tool with `pr` to write the body. Give it:

- **The title**: the title of the issue, or the subject of the commit.
- **The evidence**: the `<criterion> · <test>` lines of each commit message, the result of the cold read and each override reason. For a bug, the regression test.
- **The closing line**: `Closes #<n>`, or `Refs #<n>` for a bug whose cause is not confirmed. A branch with no issue has no closing line.
- **The merge line**: `Merge with <merge method>.`

Write the body to a file in the worktree root. Run `gh pr edit <pr> --body-file <file>`, then delete the file.

Completion: the PR has a body with each of these parts, and `git status` is clean.

## 9. Wait for CI

Skip this step when step 4 found that CI does not cover the PR.

Wait for the last watch to end. It can exit non-zero when every check passed, so read the result with `gh pr checks <pr>` each time it ends. While a check is pending, start a new watch.

- **A check failed**: show the job name and the end of `gh run view <run> --log-failed`. Fix nothing, because the user decides how to fix it.
- **No check was reported**: CI did not start, for example because of a `paths` filter. Start a subagent to run the full suite, the typecheck, the lint and the build, once, and name the gap in the report.

Completion: each check passed, or you showed each failure, or the local checks ran because CI did not start.

## 10. Mark ready

Run `gh pr ready <pr>` when the PR is a draft, step 6 has no open hard finding, and no check failed. When a check failed or a hard finding is open, a draft stays a draft, and the report names each failure and finding, also on a PR that was never a draft.

Completion: each hard finding is closed and each check passed with the PR ready, or the report names what is open.

## Report

Start with a short summary, three lines or fewer. Do not show the PR body.

```markdown
- <what changed> · because <why, from the issue's problem or the bug's cause>
```

Then: PR URL and its state · hard-stop check · cold read result, with each judgment call · CI result, or `no CI on PRs to <trunk>` with where the checks ran · next step: merge with <merge method>, then `/cleanup`.
