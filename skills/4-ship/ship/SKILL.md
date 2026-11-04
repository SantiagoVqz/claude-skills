---
name: ship
description: "Open the PR for a reviewed spec or lone ticket, or a fixed bug: rebase on the trunk, write the body, open the PR, and wait for CI to pass."
disable-model-invocation: true
argument-hint: "[spec | issue]"
---

# Ship

`/ship` turns a reviewed branch into one PR that the team can read. It reviews nothing: `/build` closes with `final-review`, and CI runs the checks. It ends with the PR open and ready for review, CI finished, and a short summary for the user. The merge is always the user's, with the method that step 1 finds.

After `EnterWorktree`, run one plain shell command per call, from the worktree root, on paths in the worktree. For a subfolder, use a flag such as `pnpm --dir` or `uv --directory`, because a `cd` stays in effect for the rest of the session. Change a file with the Edit tool, and make a new file with the Write tool. Quote each argument that holds `*`, `[` or `]`. The guard refuses only some other forms, such as a `&&` chain, `$(...)` or a heredoc, so a command that ran is no proof that its form is safe.

## 1. Load

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/setup-skills`, and stop.

Find the target from the argument, or from the current branch:

- **Spec**: an issue with the `spec` label, and its branch `spec/<n>-<slug>`.
- **Lone ticket**: an issue with an `approach:` label and no parent, with its branch `fix/<n>-<slug>`.
- **Bug**: an issue with the `bug` label, with its branch `fix/<n>-<slug>` from `/diagnose`.

Find the **merge method**. Search `docs/adr/` for "merge commit", and read `gh repo view --json rebaseMergeAllowed,mergeCommitAllowed`. An ADR that needs merge commits wins. Otherwise use rebase and merge when the repo allows it, so that each phase stays one commit on the trunk, and a merge commit when it does not.

Completion: you have the issue, its branch, the trunk, as the `worktree` skill finds it, and the merge method.

## 2. Gate

For a spec or a lone ticket, read the latest comment on the issue that starts with `### Review of #<n>`.

- **A phase has no commit**: stop. Find the phases as `final-review` does. The next step is `/build <n>`, which resumes.
- **No review comment**: stop. The next step is `/build <n>`, which resumes at the review.
- **The branch head is not the reviewed commit**: stop. A commit came after the review. The next step is `/final-review <n>`.

A bug needs no review comment: `/diagnose` ran `verify` on the fix.

Completion: the branch head is the reviewed commit, or the target is a bug that passed `verify`.

## 3. Rebase

Call `EnterWorktree` with the path of the worktree that has the branch. When the current directory is already that worktree, skip the call. Run `git fetch origin`, then `git rebase origin/<trunk>`.

- **Clean**: go to step 4. The review still counts.
- **Conflict**: call the Skill tool with `resolve-conflicts`. Then run `verify` in a subagent with a fresh context, with the issue and the diff `origin/<trunk>...HEAD`. A hard finding stops `/ship`. CI or step 4 runs every check on the resolved code, so the review still counts.

Completion: the branch is on the latest trunk, and each conflict is resolved, or `/ship` stopped.

## 4. Checks without CI

A workflow file is no proof that CI runs on this PR. Some repos have workflows that run only on `main` while the trunk is `develop`. Read the `on:` block of each file that `git ls-files .github/workflows` lists. **CI covers the PR** when a workflow has `pull_request` or `pull_request_target`, and its `branches` is missing or matches `<trunk>`, and its `branches-ignore` does not match `<trunk>`.

- **CI covers the PR**: skip this step. CI runs the checks on the PR in step 7.
- **CI does not cover the PR, and the branch head is the reviewed commit**: skip this step. The checks of `final-review` ran on this exact code. Name the gap in the report.
- **Any other case**: start a subagent to run the full suite, the typecheck, the lint and the build, under the shell rules of `/build`, because nothing else runs them on the rebased code. Wait for its result before step 5, so that no check still runs when the user merges. When the repo has no script for a check, skip that check and name it in the report. A failure stops `/ship`. Show its output.

Completion: CI covers the PR, or the head is the reviewed commit, or every check passes.

## 5. Write the body

Call the Skill tool with `pr` to write the body. Give it:

- **The title**: the title of the spec or the issue.
- **The evidence**: for a spec or a lone ticket, the story list and the Verified lines of the review comment, and its link. For a bug, the regression test.
- **The closing line**: `Closes #<n>`.
- **The merge line**: `Merge with <merge method>.`

Completion: you have the title and a body with each of these parts.

## 6. Open

Run `git push --force-with-lease origin <branch>`. Write the body to a file in the worktree root. Run `gh pr create --base <trunk> --head <branch> --title "<title>" --body-file <file>`. When the branch already has an open PR, run `gh pr edit <pr> --body-file <file>` in its place. Then delete the file.

Completion: the PR is open, ready for review, and `git status` is clean.

## 7. Watch CI

Skip this step when step 4 found that CI does not cover the PR.

Run `gh pr checks <pr> --watch` in the background, and wait for it to end. It can exit non-zero when every check passed, so read the result with `gh pr checks <pr>` each time it ends.

- **A check failed**: show the job name and the end of `gh run view <run> --log-failed`. Fix nothing. A fix is a commit after the review, so the user decides how to fix it.
- **No check was reported**: CI did not start, for example because of a `paths` filter. Run the checks of step 4, and name the gap in the report.

Completion: each check passed, or you showed each failure, or the checks of step 4 ran because CI did not start.

## Report

Start with a short summary, three lines or fewer. Do not show the PR body.

```markdown
- <what changed> · because <why, from the spec's problem or the bug's cause>
```

Then: PR URL · spec, lone ticket or bug · CI result, or `no CI on PRs to <trunk>` with where the checks ran · next step: merge with <merge method>, then `/cleanup`.
