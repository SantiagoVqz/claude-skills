---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
---

Implement the work described by the user in the spec or tickets.

**Worktree.** One worktree per spec, so separate specs can run in parallel. If this ticket is the first of its spec, create the spec's worktree and branch off the trunk, then provision it:

```bash
git worktree add .claude/worktrees/<spec-slug> -b <type>/<spec-number>-<spec-slug> <trunk>
cd .claude/worktrees/<spec-slug> && scripts/provision.sh      # add `db` when the spec adds migrations
```

The branch name carries the spec number so `provision.sh` can derive a port pair from it. If the repo has no `scripts/provision.sh`, copy [provision.sh](./provision.sh) from this folder into the repo and edit only its CONFIG block. Every later ticket of the same spec runs in that worktree, on that branch; confirm you are in it before writing code.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.
