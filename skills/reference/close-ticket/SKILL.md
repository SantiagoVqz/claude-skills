---
name: close-ticket
description: "Close a ticket or a spec issue against its acceptance criteria once its work is committed. Reads the ticket, checks each criterion against the diff, ticks the met ones on the tracker, and closes with the commit or PR as the closing comment; unmet criteria leave it open and come back verbatim. Use when a ticket's commit lands (from /dispatch or by hand) or when /ship closes a spec."
argument-hint: [ticket] [commit-or-pr]
---

# close-ticket — close against the acceptance criteria

Input: a ticket reference and a closing reference. The ticket is an issue number or a local `.scratch/<slug>/issues/<NN>-<slug>.md` file, read through the configured tracker (`docs/agents/issue-tracker.md`). The closing reference is a commit hash on the spec branch, or a PR URL when the ticket is the spec issue.

The ticket closes only when every acceptance criterion is met. A ticket closed with an unmet criterion hides work that is still open. A ticket left open with all criteria met hides work that is done. Both break the board that `/dispatch` and the human read.

## 1. Read the ticket and the change

Fetch the ticket with its body and comments. List its acceptance criteria: the `- [ ]` and `- [x]` lines. Read the change: `git show <hash>` for a commit; for a PR, `git log <trunk>..<spec-branch>` and the ticket closing comments of the spec's tickets.

Completion: every criterion is on a list, each with the evidence that meets it or the reason it is not met. A criterion the diff does not touch is not met. A criterion only a human can verify (a visual check, a production run) is not met; say so in the report.

## 2. Tick the met criteria

Flip each met criterion from `- [ ]` to `- [x]` through the tracker's tick operation. Leave unmet criteria as they are. A criterion that was already ticked stays ticked.

Completion: the ticket body on the tracker shows a tick for each met criterion.

## 3. Close or report

- **All criteria met**: close through the tracker's close operation. The closing comment is the closing reference plus one line per criterion with its evidence. That comment is the only link from the ticket to the code until a PR exists.
- **Any criterion unmet**: leave the ticket open. Append a comment that lists the unmet criteria. Report them verbatim so the caller can act on them.

Completion: the ticket is closed with a closing comment, or open with an unmet list on the ticket and in the report.

## Report

`<ticket> · closed <ref> · <n>/<m> criteria` or `<ticket> · open · unmet: <criterion>; <criterion>`.
