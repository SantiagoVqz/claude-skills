# Tracker: GitHub

Ideas, specs, tasks and bugs for this repo are GitHub issues. Use the `gh` CLI. It finds the repo from `git remote`.

## Shapes

- **Project**: an issue with the `project` label. Its sub-issues are specs, each one PR.
- **Spec**: an issue with the `spec` label, alone or a sub-issue of a project. Its plan is a comment that starts with `### Plan of #<n>`, and its review a comment that starts with `### Review of #<n>`.
- **Task**: an issue with one `approach:` label and no parent. `/build` builds it as a lone ticket.
- **Bug**: an issue with the `bug` label and no parent.
- **Idea**: an issue with the `idea` label, not yet a spec.

## Operations

- **Create**: `gh issue create --title "..." --body-file <file> --label <label>`. Add `--parent <n>` for a sub-issue.
- **Read**: `gh issue view <n> --json number,title,body,labels,state,assignees,parent,subIssues,blockedBy,comments`.
- **Block**: `gh issue edit <n> --add-blocked-by <n>,<n>`. An issue is ready when every issue in its `blockedBy` is closed.
- **Start**: `gh issue edit <n> --add-label in-progress --add-assignee @me`.
- **Edit the body**: `gh issue edit <n> --body-file <file>`.
- **Comment**: `gh issue comment <n> --body-file <file>`.
- **Close**: remove `in-progress`. Write the comment to a file with the Write tool. Run `gh issue comment <n> --body-file <file>`, then `gh issue close <n> --reason completed`. Delete the file.

## Closing keywords

`Closes #<n>` in a PR body closes the issue on merge only when the PR targets the default branch. For a PR to another branch, `/cleanup` closes the issues by hand.

## Labels

| Label | Meaning |
|---|---|
| `project` | A project. Its sub-issues are its child specs. |
| `spec` | A spec. `/build` posts its plan as a comment. |
| `bug` | A bug, fixed by `/diagnose`. |
| `idea` | An idea, not yet a spec. `/spec` or `/prd` takes it. |
| `approach:tdd` | `/build` uses the `tdd` skill. |
| `approach:refactor` | `/build` uses the `refactor` skill. |
| `approach:diagnose` | `/build` uses the `diagnose` skill. |
| `in-progress` | A person or agent works on it now. The assignee is that person. |
