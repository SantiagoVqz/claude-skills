---
name: implement
description: Implement a ticket or spec end to end — grounded, test-first, verified.
disable-model-invocation: true
---

# Implement

Implement the work described by the ticket or spec the user names. Loopable: one invocation takes one ticket from ready to committed.

0. **Worktree.** Confirm you're in the ticket's worktree on its branch off the trunk. If not, create it (`git worktree add`) and provision it with `scripts/provision.sh` (plus `provision.sh db` when the repo clones a per-worktree DB) so the worktree is manually testable before any code changes.

1. **Ground.** Read the ticket in full. Read any `.claude/rules/` matching the scope of the work, `CONTEXT.md` for vocabulary, and the ADRs in the area you're touching.

2. **Confirm the seams.** Use the seams the spec or ticket already agreed; if none exist, propose them and confirm with the user before writing any test.

3. **Build with `/tdd`** at those seams — one slice at a time. Run typechecking and the relevant single test file each cycle.

4. **Verify.** Run the full test suite and lint once at the end. On any failure, read the specific error message and remediate — up to 3 attempts per failure, then stop and report exactly what's still failing.

5. **Check against the ticket.** Every acceptance criterion accounted for; anything not delivered called out explicitly.

6. **Commit** to the current branch.
