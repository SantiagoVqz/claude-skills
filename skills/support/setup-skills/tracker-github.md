# Tracker: GitHub

Ideas, specs, tasks and bugs for this repo are GitHub issues. Use the `gh` CLI. It finds the repo from `git remote`.

## Shapes

- **Spec**: an issue with the `spec` label. Its sub-issues are its tickets, each one PR.
- **Ticket**: an issue with a spec as its parent. `/build` builds it.
- **Task**: an issue with no parent and no kind label. `/build` builds it as one ticket.
- **Bug**: an issue with the `bug` label and no parent.
- **Idea**: an issue with the `idea` label, not yet a spec.

`/build` posts a plan as a comment that starts with `### Plan of #<n>`.

## Operations

- **Create**: `gh issue create --title "..." --body-file <file> --label <label>`. Add `--parent <n>` for a sub-issue.
- **Read**: `gh issue view <n> --json number,title,body,labels,state,assignees,parent,subIssues,blockedBy,comments`.
- **Block**: `gh issue edit <n> --add-blocked-by <n>,<n>`. An issue is ready when every issue in its `blockedBy` is closed.
- **Start**: `gh issue edit <n> --add-assignee @me`.
- **Edit the body**: `gh issue edit <n> --body-file <file>`.
- **Comment**: `gh issue comment <n> --body-file <file>`.
- **Close**: write the comment to a file with the Write tool. Run `gh issue comment <n> --body-file <file>`, then `gh issue close <n> --reason completed`. Delete the file.

## Closing keywords

`Closes #<n>` in a PR body closes the issue on merge only when the PR targets the default branch. For a PR to another branch, `/cleanup` closes the issues by hand.

## Labels

| Label | Meaning |
|---|---|
| `spec` | A spec. Its sub-issues are its tickets. |
| `bug` | A bug, fixed by `/diagnose`. |
| `idea` | An idea, not yet a spec. `/spec` takes it. |
