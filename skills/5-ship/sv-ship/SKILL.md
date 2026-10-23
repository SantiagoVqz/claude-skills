---
name: sv-ship
description: "Open the PR for a reviewed spec branch or a fix branch: rebase on the trunk, run the checks, write the body, and watch CI."
disable-model-invocation: true
argument-hint: "[spec | issue]"
---

# Ship

`/sv-ship` turns a branch into one PR that the team can read. It ends with the PR open and ready for review, CI finished, and a short summary for the user. The merge is always the user's, with rebase and merge, so that each ticket stays one commit on the trunk.

After `EnterWorktree`, run one plain shell command per call, from the worktree root, on paths in the worktree. For a subfolder, use a flag such as `pnpm --dir` or `uv --directory`, because a `cd` stays in effect for the rest of the session. Change a file with the Edit tool, and make a new file with the Write tool. Quote each argument that holds `*`, `[` or `]`. The guard refuses only some other forms, such as a `&&` chain, `$(...)` or a heredoc, so a command that ran is no proof that its form is safe.

## 1. Load

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/sv-setup-skills`, and stop.

Find the target from the argument, or from the current branch:

- **Spec**: an issue with the `spec` label, and its branch `spec/<n>-<slug>`.
- **Issue**: a bug, or a lone ticket, which has no parent spec, with its branch `fix/<n>-<slug>`.

Completion: you have the issue, its branch and the trunk, as the `sv-worktree` skill finds it.

## 2. Gate

For a spec, read the latest comment on the spec issue that starts with `### Review of #<spec>`.

- **No review comment**: stop. The next step is `/sv-review <spec>`.
- **The branch head is not the reviewed commit**: stop. A commit came after the review. The next step is `/sv-review <spec>`.
- **The comment says full, and a ticket is open now**: stop, and name the ticket.

Take full or partial from the comment. A partial review lists the open tickets.

An issue needs no review comment. For a bug, `/sv-diagnose` ran `sv-verify` on the fix. For a lone ticket, `/sv-build` ran `sv-verify` on the ticket.

Completion: the branch head is the reviewed commit, and you know full or partial, or the target is an issue that passed `sv-verify`.

## 3. Rebase

Call `EnterWorktree` with the path of the worktree that has the branch. When the current directory is already that worktree, skip the call. Run `git fetch origin`, then `git rebase origin/<trunk>`.

- **Clean**: go to step 4. The review still counts.
- **Conflict on a spec**: call the Skill tool with `sv-resolve-conflicts`. The code changed, so the review no longer counts. Push nothing, and stop. The next step is `/sv-review <spec>`.
- **Conflict on an issue**: call the Skill tool with `sv-resolve-conflicts`. Then run `sv-verify` in a subagent with a fresh context, with the issue and the diff `origin/<trunk>...HEAD`. A hard finding stops `/sv-ship`.

Completion: the branch is on the latest trunk, and each conflict is resolved, or `/sv-ship` stopped.

## 4. Run the checks

Run the full suite, the typecheck, the lint and the build. When the repo has no script for a check, skip that check and name it in the report. A failure stops `/sv-ship`. Show its output.

Completion: every check passes.

## 5. Write the body

Call the Skill tool with `sv-pr` to write the body. Give it:

- **The title**: the title of the spec or the issue.
- **The evidence**: for a spec, the story list and the Verified lines of the review comment, and its link. For a bug, the regression test. For a ticket, its acceptance criteria with their tests.
- **The closing line**: `Closes #<n>` for a full spec or an issue. `Part of #<spec>` for a partial spec, with the list of open tickets.
- **The merge line**: `Merge with rebase and merge.`

Completion: you have the title and a body with each of these parts.

## 6. Open

Run `git push --force-with-lease origin <branch>`. Write the body to a file in the worktree root. Run `gh pr create --base <trunk> --head <branch> --title "<title>" --body-file <file>`. When the branch already has an open PR, run `gh pr edit <pr> --body-file <file>` in its place. Then delete the file.

Completion: the PR is open, ready for review, and `git status` is clean.

## 7. Watch CI

Run `git ls-files .github/workflows`. Skip this step when the output is empty.

Run `gh pr checks <pr> --watch` in the background, and wait for it to end. When a check fails, show the job name and the end of `gh run view <run> --log-failed`. Fix nothing. A fix is a commit after the review, so the user decides: a CI fix, or a gap for `/sv-build`.

Completion: each check passed, or you showed each failure.

## Report

Start with a short summary, three lines or fewer. Do not show the PR body.

```markdown
- <what changed> · because <why, from the spec's problem or the bug's cause>
```

Then: PR URL · full, partial or issue · CI result · next step: merge with rebase and merge, then `/sv-cleanup`.
