---
name: promote-feature
description: Promote a deferred-features stub into a ralph-loop-ready scope — moves the doc out of docs/deferred/, optionally writes a PRD, creates GitHub issues with a feature/<slug> label, and initializes the plans/ directory. Use when the user wants to start work on a deferred feature, mentions "promote feature X", "let's build feature X next", or wants to make a docs/deferred/ entry actionable.
---

# Promote Feature

Take a `docs/deferred/<slug>.md` stub and end with everything a ralph-loop needs to start work: a PRD doc at `docs/prds/feature-<slug>.md`, a `feature/<slug>` GitHub label, one or more sub-issues, and an initialized `plans/feature/<slug>/` directory.

This skill orchestrates `/write-a-prd` and `/prd-to-issues` rather than re-implementing them. It is the on-ramp that turns "we should build X someday" into "ralph can start on X right now."

## Process

### 1. Locate the stub

Argument forms:

- `/promote-feature <slug>` — look for `docs/deferred/<slug>.md` directly.
- `/promote-feature` (no arg) — `ls docs/deferred/` and present the contents to the user via `AskUserQuestion` (one option per stub, up to 4; if more than 4, ask the user to re-invoke with a slug).

If the matched file does not exist, fail loudly with `ls docs/deferred/` output so the user can see what's actually available. Do not invent a stub.

If the matched file exists, read it fully so you can pass it as context to downstream skills.

### 2. Confirm repo + label

Resolve the GitHub repo: `gh repo view --json nameWithOwner -q .nameWithOwner`. Use this as the default `--repo` for all `gh` calls below.

The label name is **always** `feature/<slug>` (slash-namespaced so features cluster in the GitHub label UI alongside `phase-N`). Do not deviate from this convention.

### 3. Size the work

Ask via `AskUserQuestion` with three options:

- **Small (1 issue, single ralph iteration).** No umbrella PRD. The deferred stub is moved as-is, light editing only. One sub-issue is filed pointing at the doc via `## Parent doc`.
- **Medium (2–4 issues, no umbrella PRD).** Move the stub, lightly expand it, then chain `/prd-to-issues` against the doc. Sub-issues use `## Parent doc`.
- **Large (PRD + many sub-issues).** Chain `/write-a-prd` (with the stub passed as `--source`) to produce a full PRD doc + GitHub umbrella issue, then `/prd-to-issues` against the umbrella issue. Sub-issues use `## Parent PRD`.

The size determines steps 5–6 below.

### 4. Move the doc

```bash
git mv docs/deferred/<slug>.md docs/prds/feature-<slug>.md
```

Use `git mv` (not plain `mv`) so the move is tracked as a rename in git history. The deferred-features convention says "do not delete a `docs/deferred/` entry — promote it to a PRD when pulled into scope" — `git mv` is exactly that promotion.

If the destination path already exists, stop and ask the user. Don't overwrite.

### 5. Expand the doc (medium / large only)

- **Medium:** edit the moved doc to add structure suitable for slicing into 2–4 issues. At minimum: a "Solution" section with discrete deliverables and an "Acceptance criteria" section (checkbox list). The user reviews the edit before step 6 starts.
- **Large:** invoke the `write-a-prd` skill with the moved doc as the source. Tell `write-a-prd` to skip its "ask for a long description" step since you have the source. The end of `write-a-prd` files an umbrella PRD issue on GitHub — capture the issue number, you'll need it for `/prd-to-issues`.
- **Small:** skip — the existing doc is enough for a single sub-issue.

### 6. Create the label and file the issue(s)

**Label first** (idempotent — safe to re-run):

```bash
gh label list --repo <owner/repo> --json name -q '.[].name' | grep -qx "feature/<slug>" \
  || gh label create "feature/<slug>" --repo <owner/repo> --color "0e7490" --description "feature scope (consumed by ralph-loop)"
```

The color `#0e7490` (cyan-700) is a sensible default — distinct from the grey-progression `phase-N` labels and from the semantic red/green palette. Override if the project has a different convention.

**Then file the issue(s):**

- **Small:** create one issue manually with `gh issue create --label feature/<slug> --title "<concise title>" --body-file -` and a body that includes `## Parent doc`, `## What to build`, `## Acceptance criteria`, and `## Blocked by None - can start immediately`.
- **Medium:** invoke the `prd-to-issues` skill with the moved doc as the PRD source. It will handle issue creation (and re-create the label idempotently — it's safe).
- **Large:** invoke `prd-to-issues` with the umbrella PRD issue from step 5 as the source.

### 7. Initialize plans/ and seed prd.json

```bash
mkdir -p plans/feature/<slug>
bash plans/sync_issues.sh feature/<slug>
```

`sync_issues.sh` reads the GitHub issues you just created and writes `plans/feature/<slug>/prd.json`. If it errors with "No issues carry the label", something went wrong in step 6 — investigate, don't paper over.

### 8. Print the ralph run command

End the skill with a clear next-step printout:

```
✓ feature/<slug> is ralph-ready.

  PRD doc:    docs/prds/feature-<slug>.md
  Label:      feature/<slug>
  Issues:     <list of issue numbers and titles>
  Plans dir:  plans/feature/<slug>/

To start the loop:
  bash plans/ralph.sh feature/<slug> 5 --interactive

For autonomous (--print) mode, drop the --interactive flag.
```

Do NOT auto-run ralph. The user explicitly chooses when to start the loop — running it is a separate, explicit action.

## Idempotency

Every step in this skill should be safe to re-run:
- The `git mv` step fails loudly if destination exists (not a silent overwrite).
- Label creation is idempotent (check-then-create).
- `prd-to-issues` only files new issues for slices the user approves; it does not re-file existing ones.
- `sync_issues.sh` is idempotent by design.

If the user re-invokes `/promote-feature <slug>` after partial completion (e.g. interrupted mid-PRD), detect the partial state (doc already moved? label already exists? issues already filed?) and resume rather than restart.

## When NOT to use this skill

- The work is a **bug fix** or a **single-line tweak** — file an issue manually, no orchestration needed.
- The work is a **phase** rather than a feature — use the existing phase-N convention. This skill is specifically for post-roadmap, off-phase features.
- The work is a **rename / refactor / dependency bump** — those don't have a deferred-stub origin and don't fit the PRD shape.
