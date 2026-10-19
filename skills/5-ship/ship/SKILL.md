---
name: ship
description: "Open the PR for a reviewed spec branch or a fix branch: rebase on the trunk, run the checks, write the body, and watch CI."
disable-model-invocation: true
argument-hint: "[spec | bug]"
---

# Ship

`/ship` turns a branch into one PR that the team can read. It ends with the PR open and ready for review, and CI finished. The user approves the PR body before the PR opens. The merge is always the user's, with rebase and merge, so that each ticket stays one commit on the trunk.

After `EnterWorktree`, run one plain shell command per call from the worktree root, with no `cd`, no `-C`, no `&&` chain and no path outside the worktree. Write files with the Write tool.

## 1. Load

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/setup-skills`, and stop.

Find the target from the argument, or from the current branch:

- **Spec**: an issue with the `spec` label, and its branch `spec/<n>-<slug>`.
- **Bug**: an issue with the `bug` label, and its branch `fix/<n>-<slug>`.

Completion: you have the issue, its branch and the trunk, as the `worktree` skill finds it.

## 2. Gate

For a spec, read the latest comment on the spec issue that starts with `### Review of #<spec>`.

- **No review comment**: stop. The next step is `/review <spec>`.
- **The branch head is not the reviewed commit**: stop. A commit came after the review. The next step is `/review <spec>`.
- **The comment says full, and a ticket is open now**: stop, and name the ticket.

Take full or partial from the comment. A partial review lists the open tickets.

A bug needs no review comment. `/diagnose` ran `verify` on the fix.

Completion: the branch head is the reviewed commit, and you know full or partial, or the target is a bug.

## 3. Rebase

Call `EnterWorktree` with the path of the worktree that has the branch. Run `git fetch origin`, then `git rebase origin/<trunk>`.

- **Clean**: go to step 4. The review still counts.
- **Conflict on a spec**: call the Skill tool with `resolve-conflicts`. The code changed, so the review no longer counts. Push nothing, and stop. The next step is `/review <spec>`.
- **Conflict on a bug**: call the Skill tool with `resolve-conflicts`. Then run `verify` in a subagent with a fresh context, with the bug issue and the diff `origin/<trunk>...HEAD`. A hard finding stops `/ship`.

Completion: the branch is on the latest trunk, and each conflict is resolved, or `/ship` stopped.

## 4. Run the checks

Run the full suite, the typecheck, the lint and the build. A failure stops `/ship`. Show its output.

Completion: every check passes.

## 5. Write the body

Call the Skill tool with `pr` to write the body. Give it:

- **The title**: the title of the spec or bug issue.
- **The evidence**: for a spec, the Stories and Verified lines of the review comment, and its link. For a bug, the regression test.
- **The closing line**: `Closes #<n>` for a full spec or a bug. `Part of #<spec>` for a partial spec, with the list of open tickets.
- **The merge line**: `Merge with rebase and merge.`

Completion: you have the title and a body with each of these parts.

## 6. Approve

Show the title and the full body in the chat. Ask with the question tool: "Approve" or "Change". On Change, edit the body, show it again and ask again. When Change comes with no notes, ask in the chat what to change. A free-text answer that clearly approves counts as Approve. Start the reply with: "Taking that as Approve." When the question returns no answer, ask it again before any other action.

Completion: the user approved the title and the body.

## 7. Open

Run `git push --force-with-lease origin <branch>`. Write the body to a file in the worktree root. Run `gh pr create --base <trunk> --head <branch> --title "<title>" --body-file <file>`. When the branch already has an open PR, run `gh pr edit <pr> --body-file <file>` in its place. Then delete the file.

Completion: the PR is open, ready for review, with the approved body, and `git status` is clean.

## 8. Watch CI

Skip this step when the repo has no `.github/workflows` folder.

Run `gh pr checks <pr> --watch` in the background, and wait for it to end. When a check fails, show the job name and the end of `gh run view <run> --log-failed`. Fix nothing. A fix is a commit after the review, so the user decides: a CI fix, or a gap for `/build`.

Completion: each check passed, or you showed each failure.

## Report

PR URL · full, partial or bug · CI result · next step: merge with rebase and merge, then `/cleanup`.
