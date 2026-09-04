---
name: ship
description: "Ship a branch as a documented PR. Spec mode: rebase the spec branch, run the full suite, push, open or update the PR with the spec record as its body, close the spec issue. One-off mode: commit the current change, branch off the trunk if needed, and open the PR with a change record. Use when every ticket of a spec is closed (from /dispatch or by hand), or for a one-off change instead of /cpr. Never merges."
argument-hint: [spec | --one-off [issue]]
---

# ship — one branch, one documented PR

`/ship` lands a branch on the remote as a pull request whose body is a **record**: the same shape on every PR, so the PR list reads as documentation. Ship owns the git that leaves the machine and the record. The merge stays the human's call. Post-merge teardown is `/cleanup` for a spec; a one-off has nothing to tear down.

## Mode

Ship runs in one of two modes. Pick it in step 1 and say which one in the report.

- **Spec**: the branch is `<type>/<spec-number>-<spec-slug>`, held by the worktree `.claude/worktrees/<spec-slug>`, and `<spec-number>` resolves on the tracker (`docs/agents/issue-tracker.md`). Every ticket is closed or parked. Ship does not commit here; `/implement` and `/dispatch` own the commits and the ticket closes.
- **One-off**: any other branch, the trunk with uncommitted work, or `--one-off` given. Ship commits the work and opens the PR. An issue number in `$ARGUMENTS`, the branch name, or a commit message is the change's issue.

`$ARGUMENTS` names the spec, or `--one-off` with an optional issue. With no argument, read the mode from the current branch.

## Vocabulary

- **Trunk**: the branch the repo merges into (`develop` on a git-flow repo, `main` otherwise); same rule as `/cleanup`.
- **Base**: the branch the PR targets. The trunk for a new PR, the PR's own `baseRefName` for one that exists.
- **Record**: the PR body. Spec mode writes the spec record, one-off mode the change record; both carry the same section order.
- **Decision**: an ADR, a `CONTEXT.md` edit, or a `docs/` change in the diff. Every record names each one, so a reader finds the decision from the PR.

## 1. Preflight

Run every git command inside the branch's worktree.

**Spec mode.**

- Head is the spec branch, never the trunk or the default branch.
- `git status --porcelain` is empty. A dirty tree goes back to `/implement`.
- From the tracker, list the spec's tickets. Every ticket is closed, or parked with the human's say-so in this conversation. An open ticket that is not parked stops the run: name it and hand back to `/dispatch`.

Completion: on a clean spec branch with a ticket list where every row reads closed or parked.

**One-off mode.**

- Read `git status` and `git diff` for the whole change, staged and unstaged.
- On the trunk or the default branch: create a branch off it first, `<type>/<slug>` with the type inferred from the change (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`).
- Stage and commit the work. The message follows the repo's commit style and the writing rules in `CLAUDE.md`: a short subject, then the reason. Name any decision the diff carries.
- A clean tree with commits already on the branch skips the commit.

Completion: on a non-trunk branch with a clean tree and the change committed.

## 2. Fetch and read the base

`git fetch --all --prune`. Then `gh pr view --json number,url,baseRefName,state`:

- A PR exists: the branch is **under review**; base = its `baseRefName`.
- No PR: the branch is **new**; base = the trunk.

Completion: one line states `head ← base` and whether the branch is new or under review.

## 3. Integrate the base

`git rev-list --count HEAD..origin/<base>` greater than zero means the base moved. Zero: skip to step 4.

- **New**: `git rebase origin/<base>`. No review threads exist yet, so take the linear history.
- **Under review**: `git merge origin/<base>`. A rebase discards review threads and approvals.

On conflict run `/resolving-merge-conflicts`; finish the operation, never abort it.

Completion: `git rev-list --count HEAD..origin/<base>` is zero.

## 4. Full suite

Run the repo's complete suite, plus typecheck and lint where the repo has them, on the current head. In spec mode each ticket ran the suite on its own commit; this run proves the combination on top of the moved base. In one-off mode this is the only run.

Red: stop. Report the failing test and leave the branch unpushed. Fix on the branch, commit, and run `/ship` again.

Completion: green.

## 5. Push

- No `origin/<head>` yet: `git push -u origin <head>`.
- After a rebase: `git push --force-with-lease`. It aborts when the remote moved after the fetch.
- Otherwise: `git push`.

Completion: `origin/<head>` equals local `HEAD`.

## 6. Write the record

List the decisions in the diff first: `git diff <base>...HEAD --name-only` filtered to ADR files, `CONTEXT.md`, and `docs/`. Read each one so the record can state the decision in one line.

**Spec record.** Gather from the tracker and the branch: the spec's title and goal from the spec issue body; every ticket with its number, title, closing commit (`git log <trunk>..HEAD --grep '<ticket ref>'`), and state; the spec issue's own acceptance criteria; the suite result.

```markdown
## Spec

<spec ref> <spec title>. <one paragraph: the goal, and what a user can now do>

## Tickets

| Ticket | Title | Commit | State |
| --- | --- | --- | --- |
| #12 | ... | abc1234 | closed |
| #13 | ... | — | parked: <reason> |

## Acceptance criteria

- [x] <criterion> — <evidence>
- [ ] <criterion> — <why it is not met>

## Decisions

- <ADR-0007 title>: <the decision in one line> (`docs/adr/0007-....md`)
- None

## Verification

Full suite green on <short hash> after rebase onto <base>. <typecheck, lint>

## Left open

<parked tickets, deferred criteria, follow-ups; or "None">
```

**Change record.** Gather from the diff and the commits: what changed and why, the issue if there is one, the suite result.

```markdown
## Change

<one paragraph: what changed, and why. From the user's perspective where there is one.>

Issue: #<n> or none.

## Decisions

- <ADR title>: <the decision in one line> (`<path>`)
- None

## Verification

Full suite green on <short hash> after rebase onto <base>. <typecheck, lint>. <how to see the change, when a test does not show it>

## Left open

<follow-ups the change does not cover; or "None">
```

Completion: spec record names every ticket with a closed or parked row; change record names the issue or says none. Both name every decision in the diff or say "None".

## 7. Open or update the PR

- **New**: `gh pr create --base <base> --head <head> --title "<title>" --body-file <record>`. Spec title: `<spec ref>: <spec title>`. One-off title: the commit subject.
- **Under review**: `gh pr edit <n> --body-file <record>`. Keep the existing title.

**Spec mode** adds no `Closes` keyword. The spec issue closes in step 8 with the PR as its closing reference, so the record is on the tracker whether or not the PR merges into the default branch.

**One-off mode** with an issue puts `Closes #<n>` in the record's Change section. The issue closes when the PR merges, so the human keeps the check on it.

Completion: exactly one open PR for head, targeting base, whose body is the record.

## 8. Close the spec issue (spec mode only)

Invoke the `close-ticket` skill on the spec issue with the PR URL as the closing reference. On a local tracker, also append the record to the spec file under `## Shipped`.

A spec with parked tickets or an unmet criterion stays open: close-ticket reports the unmet list, and the record's "Left open" section carries the same list.

Completion: the spec issue is closed with the PR URL in its closing comment, or open with the unmet list on it.

## Report

`<mode> · <head> ← <base>` · new or under review · committed (one-off) · rebased, merged, or already current · suite result · pushed · PR URL, created or updated · decisions named · spec issue closed or open with the reason (spec mode).
