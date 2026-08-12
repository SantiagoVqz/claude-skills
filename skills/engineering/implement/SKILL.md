---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Step zero: run in the ticket's worktree. If you're on the trunk (primary checkout), create it first — `git worktree add ../<repo>-<slug> -b <type>/<slug>`, cd there, run `scripts/provision.sh` if the repo has one.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, run /simplify on the ticket's diff, then /two-axis-review to review the work.

Commit your work to the current branch.
