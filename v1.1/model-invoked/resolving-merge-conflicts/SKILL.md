---
name: resolving-merge-conflicts
description: "Use when you need to resolve an in-progress git merge/rebase conflict, including a cascading `gh stack rebase` that stopped on exit code 3."
---

1. **See the current state** of the merge/rebase. Check git history, and the conflicting files. In a stack, `gh stack view --json` tells you which layer stopped and what sits above it.

2. **Read the intended change** *before* resolving, so you can tell afterwards whether the diff still matches intent. `git diff <base>...<head>` (three-dot) is what this branch means to add; note the files and behaviours it is *supposed* to touch. Anything outside that set once you're done is suspect.

3. **Find the primary sources** for each conflict. Understand deeply why each change was made, and what the original intent was. Read the commit messages, check the PRs, check original issues/tickets.

4. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. Always resolve; never `--abort`.

   Stop and hand back to the human when a conflict is **semantic, not textual** — both sides changed the same behaviour in incompatible ways, and picking one silently changes the product.

5. Discover the project's **automated checks** and run them — typically typecheck, then tests, then format. Fix anything the merge broke.

6. **Finish the merge/rebase.** Stage everything and commit. If rebasing, continue until all commits are rebased (`git rebase --continue`, or `gh stack rebase --continue` inside a stack, which resumes the cascade through the remaining layers).

7. **Verify the surviving diff is exactly the intended change.** Re-read `git diff <base>...<head>` against what you noted in step 2, hunk by hunk:
   - **No conflict debris** — no leftover `<<<<<<<`, `=======`, `>>>>>>>`.
   - **No accidental base reverts** — a bad resolution can silently roll back a change the base introduced. Every base change is still present unless this branch deliberately changes it.
   - **No unrelated cruft** — stray debug output, unintended reformatting, files that snuck in during resolution. Remove them.
   - **Nothing dropped** — every behaviour the branch was supposed to add is still there.

   In a stack, run this per layer: one cascade rewrites every branch above the conflict, so a bad resolution propagates upward silently.

   Completion: you can state in plain language *"the surviving diff is exactly X, Y, Z — the intended change, nothing else"* for each branch the operation touched.
