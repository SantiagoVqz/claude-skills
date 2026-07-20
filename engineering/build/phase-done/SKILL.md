---
name: phase-done
description: "End-of-phase ritual for multi-phase work — /simplify, run the repo's own checks, commit, then a cold-read review by a fresh agent. Run after each phase during /implement, before the final /ship."
disable-model-invocation: true
---

# phase-done — close out a phase

The per-phase closer inside a multi-phase `/implement`: run it after each phase, then continue to the next — or hand to `/ship` once the last phase is done.

It is a **ritual** — pre-approved, run start to finish. Do NOT ask for permission between steps; skipping the asking is the reason it exists.

## Steps

1. **Simplify** — invoke `/simplify` on this phase's changed code (reuse, simplification, efficiency, altitude — not bug-hunting; `/code-review` owns bugs).
   Completion: `/simplify` has run and its cleanups are applied, or it found nothing.

2. **Checks** — the repo already defines what "green" means; **mirror its own checks, don't invent them.** Find them, in order of authority, and run only what the phase touched:
   - **CI** — `.github/workflows/*` names the authoritative commands. Read it first; it is the source of truth.
   - **Manifest scripts** — `package.json` (`check`/`lint`/`typecheck`/`test`), `Makefile`/`justfile` targets, `pyproject.toml` (ruff, the configured type checker, pytest). Run via the repo's package manager (pick pnpm/yarn/npm from the lockfile).
   - Scope tests to affected modules when the full suite is slow; run it whole only at the last phase.

   Fix failures **this phase caused** before proceeding. Pre-existing failures get reported, never fixed silently.
   Completion: every check the repo defines has run, and each result is green or attributed (this-phase → fixed, pre-existing → reported).

3. **Commit** in the feature branch/worktree: short present-tense summary matching the repo's log style, one logical change per commit.
   Completion: working tree clean; each commit is a single logical change.

4. **Cold-read** — spawn a fresh `Explore` agent with NO context beyond the list of files changed this phase. Prompt it to read the final state and flag what smells wrong: naming drift, half-applied renames, discriminants collapsed to `string`, dead fallbacks left behind. Triage every flag: fix the real ones now (amend or commit), dismiss false positives with a reason.
   Completion: every flagged item is either fixed or explicitly dismissed.

5. **Report** — one block: what the phase delivered · check results · commit hash(es) · cold-read findings and their disposition. Then continue to the next phase, or `/ship`.
