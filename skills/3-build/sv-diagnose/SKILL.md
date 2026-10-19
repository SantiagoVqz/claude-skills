---
name: sv-diagnose
description: "Find and fix the cause of a bug or a performance regression with a red feedback loop, ranked hypotheses and a regression test. Use when the user runs /sv-diagnose, or /sv-build runs an approach:diagnose ticket."
argument-hint: "<sentry link | error | issue>"
metadata:
  credits:
    skill: diagnosing-bugs
    author: Matt Pocock
    organisation: AI Hero
    url: "https://github.com/mattpocock/skills/blob/f3fc563/skills/engineering/diagnosing-bugs/SKILL.md"
---

# Diagnose

`/sv-diagnose` takes a bug from a symptom to one fix commit. The **loop** is the skill: one command that goes **red** on this bug and green when it is fixed. With a **tight** loop, the cause falls out of the steps that follow. With no loop, reading code gives only a guess.

When `/sv-build` runs this skill for an `approach:diagnose` ticket, skip the steps marked "(not under `/sv-build`)". `/sv-build` owns them.

After `EnterWorktree`, run one plain shell command per call from the worktree root: no `cd`, no `-C`, no `&&` chain, no `$(...)`, no shell variable and no path outside the worktree. A `cd` stays in effect for the rest of the session. For a subfolder, use a flag such as `pnpm --dir` or `uv --directory`. Write files with the Write tool.

## 1. Issue (not under `/sv-build`)

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/sv-setup-skills`, and stop.

When the input is a Sentry link or an error, create an issue with the `bug` label. The body has the symptom, redacted, and the steps to see it. Set the issue to in progress, as `tracker.md` says.

Completion: the bug is an issue in progress, and you have its number.

## 2. Worktree (not under `/sv-build`)

Call the Skill tool with `sv-worktree` for `fix/<n>-<slug>`, made from the trunk.

Completion: the session is in the fix worktree.

## 3. Loop

Read the glossary that `docs/agents/domain.md` names, and the ADRs for the area. Then build the loop. Try these in order:

1. A failing test at the seam that reaches the bug.
2. A `curl` script against a running dev server.
3. A CLI call with a fixture input, compared with a known-good output.
4. A headless browser script that drives the UI and checks the DOM, the console or the network.
5. A replay of a captured request, payload or event log through the code path.
6. A throwaway harness: the smallest part of the system that runs the code path in one call.
7. A fuzz loop: many random inputs, for output that is sometimes wrong.
8. A bisect harness: `git bisect run` between a good and a bad commit.
9. A differential loop: one input through the old and the new version, with the outputs compared.
10. A human loop. Call the Skill tool with `sv-ui-check` to show the bug in a browser first. For what a browser cannot do, ask the user with the question tool, one step for each question, and record each answer.

Then tighten it: make it faster, assert on the exact symptom, and pin the time, the random seed and the network.

For a bug that does not occur each time, raise the rate: run the trigger many times, in parallel, under load. A rate of 50% is enough to work with. A rate of 1% is not.

When you cannot build a loop, stop. List what you tried. Ask the user for access to an environment that shows the bug, a captured artifact, or approval for temporary instrumentation in production.

Completion: you have one command, and you ran it at least once. It is:

- **Red**: it runs the code path of the bug and asserts the user's exact symptom.
- **Deterministic**: each run gives the same result, or a pinned high rate.
- **Fast**: seconds, not minutes.
- **Agent-run**: you run it with no human, except through the human loop.

Do not read code to build a theory before this command exists.

## 4. Reproduce and minimise

Run the loop, and see it go red. Confirm that the failure is the user's symptom, not a different failure near it. Record the exact symptom.

Then cut one part at a time: inputs, callers, config, data and steps. Run the loop after each cut. Keep only the parts that the failure needs.

Completion: the loop is red on the user's symptom, and each part that is left makes the loop green when you remove it.

## 5. Hypothesise

Write 3 to 5 hypotheses, ranked. Each one states its prediction: "When <X> is the cause, <changing Y> makes the bug go away." A hypothesis with no prediction is a guess: sharpen it or remove it.

Ask with the question tool which hypothesis to test first. Give one option for each hypothesis, with its prediction in the description. Mark your top pick as recommended. When the question returns no answer, ask it again before any other action.

Completion: the user picked a hypothesis, or wrote their own.

## 6. Instrument

Test one prediction at a time. Change one variable at a time. Use a debugger when the environment has one. Otherwise, add logs at the boundaries that tell the hypotheses apart. Tag each debug log with one prefix, such as `[DEBUG-a4f2]`.

For a performance bug, measure a baseline first, with a timer, a profiler or a query plan. Then bisect.

When the user's pick is false, go to the next hypothesis in the ranking.

Completion: one hypothesis is confirmed by its prediction, and the others that you tested are false.

## 7. Fix

Find a **correct seam**: a seam where a test runs the real pattern of the bug, as it occurs at the call site. A seam that is too shallow, such as one caller when the bug needs two, gives false confidence.

With a correct seam:

1. Turn the minimised repro into a failing test at the seam.
2. Run it, and see it fail on the symptom. When you forced the red with a change to the code, confirm with `git diff` that the change is there, and undo it after.
3. Fix the cause.
4. Run the test, and see it pass.
5. Run the loop from step 3 on the original scenario.

With no correct seam, fix the cause and record the missing seam. The architecture keeps this bug from a regression test, and the team needs to know.

Completion: the loop is green, and the regression test passes, or the missing seam is recorded.

## 8. Cleanup

- Search for the debug prefix with `git grep`. Remove each hit.
- Delete the throwaway harnesses and scripts.
- Run the loop from step 3 one more time.

Completion: `git grep` finds no debug prefix, no throwaway file is left, and the loop is green.

## 9. Verify (not under `/sv-build`)

Start a subagent with a fresh context. Tell it to call the Skill tool with `sv-verify`, with the bug issue and the diff `origin/<trunk>...HEAD`. Fix only the hard findings, commit, and run `sv-verify` in a new subagent one more time. When a hard finding is still there, stop and show the findings. Each judgment call goes on the card.

Completion: the last `sv-verify` run has no hard finding.

## 10. Card (not under `/sv-build`)

Show one card:

```markdown
### #<n> <title>
Cause: <the confirmed hypothesis, in one line>
Fix: <one line>
Test: <test name> | Missing seam: <why>

Judgment calls:
- <one line each, from verify>

Check yourself: `<run command>`
1. <a step and what the user sees>
```

Keep "Check yourself" to three steps or fewer.

Ask with the question tool: "Approve", "Change" or "Run ui-check". Leave out "Run ui-check" when it already ran on the fix. On Run ui-check, call the Skill tool with `sv-ui-check` for this bug, then ask again with "Approve" or "Change". On Change, make the edits, commit, run `sv-verify` in a new subagent, and show the card again. When Change comes with no notes, ask in the chat what to change. A free-text answer that clearly approves counts as Approve. Start the reply with: "Taking that as Approve." When the question returns no answer, ask it again before any other action.

Completion: the user approved. Stop the dev server, and close the tab as `sv-ui-check` says, when `sv-ui-check` started them.

## 11. Record

Squash the branch into one commit, except under `/sv-build`, which squashes when it lands the ticket. Run `git merge-base HEAD origin/<trunk>`, then `git reset --soft <base>`. Commit with `-m "Fix <title> (#<n>)"`, then `-m "Cause: <the confirmed hypothesis>"`.

Comment on the issue, as `tracker.md` says: the cause, the loop command, and the missing seam when there is one.

Completion: the branch has one commit over the trunk, or `/sv-build` runs this skill, and the issue has the cause.

## Redact

Redact each secret in each command, output and artifact that you show: write `<REDACTED>` in its place. Build loops that read credentials from environment variables. Quote only the lines of a captured artifact that carry the signal. When the redacted output is not enough to find the cause, say so and ask the user.

## Excuses

| Excuse | Answer |
|---|---|

No rows yet. Add a row only when `/sv-retro` finds a new excuse.

## Report

Issue · cause · commit · missing seam, if any · next step: `/sv-ship <n>`.
