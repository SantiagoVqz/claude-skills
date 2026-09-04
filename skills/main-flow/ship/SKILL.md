---
name: ship
description: "Ship a finished spec: rebase its branch onto the trunk, run the full suite, push, open or update the PR with the spec record as its body, and close the spec issue against the record. Use when every ticket of a spec is committed and closed, from /dispatch or by hand. Never merges."
argument-hint: [spec]
---

# ship — one spec, one PR

`/ship <spec>` takes a spec branch whose tickets are all committed and closed, and lands it on the remote as a pull request. The spec is an issue number or a `.scratch/<slug>` path, resolved through the configured tracker (`docs/agents/issue-tracker.md`); with no argument, derive it from the current branch name.

Ship owns the git that leaves the machine and the record that says the spec is finished. `/implement` and `/dispatch` own the code and the ticket closes. The merge stays the human's call. Post-merge teardown is `/cleanup`.

## Vocabulary

- **Trunk**: the branch the repo merges into (`develop` on a git-flow repo, `main` otherwise); same rule as `/cleanup`.
- **Spec branch**: `<type>/<spec-number>-<spec-slug>`, held by the worktree `.claude/worktrees/<spec-slug>`.
- **Base**: the branch the PR targets. The trunk for a new PR, the PR's own `baseRefName` for one that exists.
- **Spec record**: the document that says what shipped. It is the PR body, and on a local tracker also a `## Shipped` section in the spec file.

## 1. Preflight

Run every git command inside the spec worktree.

- Head is the spec branch, never the trunk or the default branch. Refuse to ship from the trunk.
- `git status --porcelain` is empty. Ship publishes committed work; it does not commit. A dirty tree goes back to `/implement`.
- From the tracker, list the spec's tickets. Every ticket is closed, or parked with the human's say-so in this conversation. An open ticket that is not parked stops the run: name it and hand back to `/dispatch`.

Completion: on a clean spec branch with a ticket list where every row reads closed or parked.

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

Run the repo's complete suite, plus typecheck and lint where the repo has them, on the current head. Each ticket ran the suite on its own commit; this run proves the combination on top of the moved base.

Red: stop. Report the failing test and leave the branch unpushed. The fix goes through `/implement` on the spec branch, then `/ship` again.

Completion: green.

## 5. Push

- No `origin/<head>` yet: `git push -u origin <head>`.
- After a rebase: `git push --force-with-lease`. It aborts when the remote moved after the fetch.
- Otherwise: `git push`.

Completion: `origin/<head>` equals local `HEAD`.

## 6. Write the spec record

Gather from the tracker and the branch:

- The spec's title and its goal, from the spec issue body.
- Every ticket: number, title, the commit that closed it (`git log <trunk>..HEAD --grep '<ticket ref>'`), and its state.
- The spec issue's own acceptance criteria, if it has any.
- The suite result from step 4.

Compose the record with this shape:

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

## Verification

Full suite green on <short hash> after rebase onto <base>. <typecheck, lint>

## Left open

<parked tickets, deferred criteria, follow-ups; or "None">
```

Completion: the record names every ticket of the spec, and every row reads closed or parked with its reason.

## 7. Open or update the PR

- **New**: `gh pr create --base <base> --head <head> --title "<spec ref>: <spec title>" --body-file <record>`.
- **Under review**: `gh pr edit <n> --body-file <record>`. Keep the existing title.

Do not add a `Closes` keyword. The spec issue closes in step 8, with the PR as its closing reference, so the record is on the tracker whether or not the PR merges into the default branch.

Completion: exactly one open PR for head, targeting base, whose body is the spec record.

## 8. Close the spec issue

Invoke the `close-ticket` skill on the spec issue with the PR URL as the closing reference. On a local tracker, also append the record to the spec file under `## Shipped`.

A spec with parked tickets or an unmet criterion stays open: close-ticket reports the unmet list, and the record's "Left open" section carries the same list.

Completion: the spec issue is closed with the PR URL in its closing comment, or open with the unmet list on it.

## Report

`<spec> · <head> ← <base>` · new or under review · rebased, merged, or already current · suite result · pushed · PR URL, created or updated · spec issue closed or open with the reason.
