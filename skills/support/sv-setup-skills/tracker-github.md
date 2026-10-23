# Tracker: GitHub

Ideas, specs, tickets and bugs for this repo are GitHub issues. Use the `gh` CLI. It finds the repo from `git remote`.

## Shapes

- **Spec**: an issue with the `spec` label.
- **Ticket**: a sub-issue of its spec, with one `approach:` label.
- **Bug**: an issue with the `bug` label and no parent.
- **Idea**: an issue with the `idea` label, not yet a spec.

## Operations

- **Create**: `gh issue create --title "..." --body-file <file> --label <label>`. Add `--parent <spec>` for a ticket.
- **Read**: `gh issue view <n> --json number,title,body,labels,state,assignees,parent,subIssues,blockedBy,comments`.
- **List a spec's tickets**: `gh issue view <spec> --json subIssues`.
- **Block**: `gh issue edit <ticket> --add-blocked-by <n>,<n>`. A ticket is ready when every issue in its `blockedBy` is closed.
- **Start**: `gh issue edit <n> --add-label in-progress --add-assignee @me`.
- **Edit the body**: `gh issue edit <n> --body-file <file>`.
- **Comment**: `gh issue comment <n> --body-file <file>`.
- **Close**: remove `in-progress`. Write the comment to a file with the Write tool. Run `gh issue comment <n> --body-file <file>`, then `gh issue close <n> --reason completed`. Delete the file.

## Closing keywords

`Closes #<n>` in a PR body closes the issue on merge only when the PR targets the default branch. For a PR to another branch, `/sv-cleanup` closes the issues by hand.

## Labels

| Label | Meaning |
|---|---|
| `spec` | A spec. Its sub-issues are its tickets. |
| `bug` | A bug, fixed by `/sv-diagnose`. |
| `idea` | An idea, not yet a spec. `/sv-spec` or `/sv-prd` takes it. |
| `approach:tdd` | `/sv-build` uses the `sv-tdd` skill. |
| `approach:refactor` | `/sv-build` uses the `sv-refactor` skill. |
| `approach:diagnose` | `/sv-build` uses the `sv-diagnose` skill. |
| `in-progress` | A person or agent works on it now. The assignee is that person. |
