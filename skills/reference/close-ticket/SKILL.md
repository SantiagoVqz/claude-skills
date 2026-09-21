---
name: close-ticket
description: "Close a ticket against its acceptance criteria once its work is committed. Reads the ticket, checks each criterion against the diff, ticks the met ones on the tracker, and closes with the commit as the closing comment; unmet criteria leave it open and come back verbatim. Use when a ticket's commit lands, from /dispatch or by hand."
argument-hint: [ticket] [commit]
---

# close-ticket — close against the acceptance criteria

Input: a ticket reference and a commit hash. The ticket is an issue number or a `.scratch/<slug>/issues/<NN>-<slug>.md` file, read through the configured tracker (`docs/agents/issue-tracker.md`).

The ticket closes only when every acceptance criterion is met. A ticket closed with an unmet criterion hides work that is still open. A ticket left open with all criteria met hides work that is done. Both break the board that `/dispatch` and the human read.

## 1. Read the ticket and the change

Fetch the ticket with its body and comments. List its acceptance criteria: the `- [ ]` and `- [x]` lines. Read the change with `git show <hash>`.

Completion: every criterion is on a list, each with the evidence that meets it or the reason it is not met. A criterion the diff does not touch is not met. A criterion only a human can verify (a visual check, a production run) is not met, and the report marks it `needs human` so `/dispatch` hands the ticket to the human instead of retrying it.

## 2. Tick the met criteria

Flip each met criterion from `- [ ]` to `- [x]` in the ticket body. Leave unmet criteria as they are; a criterion that was already ticked stays ticked.

- GitHub: `gh issue view <n> --json body --jq .body`, edit, `gh issue edit <n> --body-file <file>`.
- GitLab: `glab issue view <n> --output json`, edit, `glab issue update <n> --description <text>`.
- Local: edit the line in the file.

Completion: the ticket body on the tracker shows a tick for each met criterion.

## 3. Close or report

- **All criteria met**: close, with a comment that carries the commit hash and one line per criterion with its evidence. GitHub: `gh issue close <n> --comment "..."`. GitLab: comment, then `glab issue close <n>`. Local: set the `Status:` line to `done` and append the comment under `## Comments`. That comment is the only link from the ticket to the code until a PR exists.
- **Any criterion unmet**: leave the ticket open. Append a comment that lists the unmet criteria. Report them verbatim so the caller can act on them.

Completion: the ticket is closed with a closing comment, or open with an unmet list on the ticket and in the report.

## Report

`<ticket> · closed <hash> · <n>/<m> criteria` or `<ticket> · open · unmet: <criterion>; needs human: <criterion>`.
