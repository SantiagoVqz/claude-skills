# Tracker: GitHub

Specs, tickets and bugs for this repo are GitHub issues. Use the `gh` CLI. It finds the repo from `git remote`.

## Shapes

- **Spec**: an issue with the `spec` label.
- **Ticket**: a sub-issue of its spec, with one `approach:` label.
- **Bug**: an issue with the `bug` label and no parent.

## Operations

- **Create**: `gh issue create --title "..." --body-file <file> --label <label>`. Add `--parent <spec>` for a ticket.
- **Read**: `gh issue view <n> --json number,title,body,labels,state,assignees,parent,subIssues,blockedBy,comments`.
- **List a spec's tickets**: `gh issue view <spec> --json subIssues`.
- **Block**: `gh issue edit <ticket> --add-blocked-by <n>,<n>`. A ticket is ready when every issue in its `blockedBy` is closed.
- **Start**: `gh issue edit <n> --add-label in-progress --add-assignee @me`.
- **Comment**: `gh issue comment <n> --body-file <file>`.
- **Close**: `gh issue close <n> --reason completed --comment "..."`. Remove `in-progress` first.

## Closing keywords

`Closes #<n>` in a PR body closes the issue on merge only when the PR targets the default branch. For a PR to another branch, `/cleanup` closes the issues by hand.

## Labels

| Label | Meaning |
|---|---|
| `spec` | A spec. Its sub-issues are its tickets. |
| `bug` | A bug, fixed by `/diagnose`. |
| `approach:tdd` | `/build` uses the `tdd` skill. |
| `approach:refactor` | `/build` uses the `refactor` skill. |
| `approach:diagnose` | `/build` uses the `diagnose` skill. |
| `in-progress` | A person or agent works on it now. The assignee is that person. |
