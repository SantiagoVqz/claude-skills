---
name: devnote
description: Capture what was done in this session — what changed, why, key decisions, gotchas, deferred work, files affected — as a dated document in the repo's knowledge base. Institutional memory for humans. Triggers: "devnote", "write a devnote", "handout", "document what we did", "capture this session", "session notes".
---

# Devnote

Write a **human-readable** knowledge-capture document at the end of a session (or on demand). A devnote records **what** changed, **why**, decisions made, surprises encountered, and files affected — so anyone (including future-you) can understand the work without re-reading the conversation.

**Comprehensibility is the primary quality.** Every sentence must earn its place — if removing it loses no information, remove it. Prefer sentence fragments and terse bullets over full paragraphs. No filler, no restating what is obvious from the code or file paths.

## Where this sits among the repo's durable artifacts

Three different questions, three different homes. Put each fact in exactly one:

| Artifact | Answers | Lifetime |
|---|---|---|
| `CONTEXT.md` | what do our words mean | living — edited in place |
| `docs/adr/` | why is the design this way | living — appended |
| devnote | what changed, why now, what bit us | **frozen** — dated snapshot |

A devnote is never edited after it's written. That is the whole point *and* its weakness: nobody re-reads devnotes systematically. So anything that must survive being un-read does **not** belong here alone — see the ADR rule and the Deferred rule below.

## Read the repo's config first

The knowledge base's location and conventions are per-repo, recorded by `/setup-skills`:

- **`docs/agents/knowledge-base.md`** — where devnotes go, whether the KB is a separate git repo, the commit posture, the search-index refresh command, and who reads it. Read this before writing anything.
- **`docs/agents/issue-tracker.md`** — the issue-reference syntax for the Deferred section.

If `docs/agents/knowledge-base.md` doesn't exist, this repo hasn't been set up. Tell the user to run `/setup-skills` (Section E) — offer to write the devnote to `docs/devnotes/YYYY-MM-DD-<slug>.md` as a one-off in the meantime, and skip the commit and index steps.

## Filename

```
<kb-path>/YYYY-MM-DD-<topic-slug>.md
```

- `YYYY-MM-DD` — today's date
- `<topic-slug>` — kebab-case summary of the topic, descriptive and grep-friendly (e.g. `whatsapp-media-url`, `invite-image-library`)
- If the name is taken, append `-2`, `-3`, …

## Session shapes

- **Multiple unrelated topics** — write one devnote per topic, each with its own slug and focused content. Never combine unrelated work into one document.
- **Discussion only** (no code written) — use status `Discussion Only`, mark "Files Affected" as N/A. These still produce valuable decision records.
- **Continuation of prior work** — name the earlier devnote's date/slug in the Summary so they read together.

## The ADR rule

Before writing "Key Decisions", test each decision against all three:

1. **Hard to reverse** — changing your mind later costs something real
2. **Surprising without context** — a future reader will ask "why did they do it this way?"
3. **A real trade-off** — there were genuine alternatives and you picked one for specific reasons

A decision passing all three belongs in an **ADR**, not only here — a frozen document nobody re-reads is the wrong home for a decision that governs future work. Write the ADR (see `/domain-modeling`), then reference it from the devnote in one line rather than restating it. Decisions failing the test stay in the devnote, where they're cheap.

## Template

Follow this structure. Don't skip sections — write "None" or "N/A" if one doesn't apply.

```markdown
# <Title: short descriptive name>

**Date**: YYYY-MM-DD
**Status**: Implemented | In Progress | Discussion Only
**Related files**: `path/to/primary-file` (1-3 key files, for quick reference)

---

## Summary

1-2 sentences. What area, what changed, what state it's in now. No background — that's what "Why" is for.

## What Changed

- Terse bullet per logical change with file path: `change description (path/to/file)`
- Group related changes into one bullet — do NOT write one bullet per file when they're part of the same change
- 5-10 bullets max. More than that means your bullets are too granular.

## Why

2-3 sentences max. Plain language. Why was this needed?

## Key Decisions

Only **non-obvious** decisions — skip anything a senior dev would do the same way. If none: "None — straightforward implementation."

1. **Decision**: one line
   - **Why**: one line
   - **Over**: alternative considered, one line

1-3 max. Anything passing the ADR test above goes in an ADR instead, referenced here in one line.

## Gotchas

- Only things that would surprise someone or waste their debugging time
- One line each

If nothing: "None."

## Deferred

- [ ] Terse task description (#123)
- [ ] Terse task description *(accept if forgotten)*

If nothing: "None."

## Files Affected

| File | Action | Notes |
|------|--------|-------|
| `path/to/file` | Created | 3-5 words |
| `path/to/other` | Modified | 3-5 words |

Action: Created, Modified, or Deleted. Notes: 3-5 words, not a sentence.

## Takeaways

- 2-4 bullets. What would you tell a teammate in 15 seconds?
```

## The Deferred rule

Every Deferred item MUST end with either an **issue reference** or the explicit marker *(accept if forgotten)*. No exceptions.

Devnotes are frozen snapshots nobody re-reads systematically — an unticketed deferred item lives only here and silently rots. So:

- Worth tracking, no issue yet → create one before writing the devnote (using the tracker in `docs/agents/issue-tracker.md`; its reference syntax varies — `#N`, `owner/repo#N`, a path under `.scratch/`, a Jira key). Ask the user first if creating issues on their behalf isn't already routine here.
- Not worth an issue → mark it *(accept if forgotten)*, so a future reader knows it was dropped **deliberately**, not lost.

## Process

1. **Review the session** — scan for code changes, decisions, problems solved, open threads.
2. **Determine topic(s)** — plan one devnote per unrelated topic.
3. **Apply the ADR rule** — promote any decision that passes all three tests, and write it before the devnote so you can reference it.
4. **Settle the Deferred items** — every one gets a ticket or the marker.
5. **Draft** using the template.
6. **Write** the file.
7. **Commit** per `docs/agents/knowledge-base.md`. When the KB is a separate repo committing straight to its main:

   ```bash
   git -C <kb-repo> add <kb-subdir>
   git -C <kb-repo> commit -m "devnote: <slug>"
   git -C <kb-repo> pull --rebase
   git -C <kb-repo> push
   ```

   The `pull --rebase` guards against another session or machine having pushed meanwhile (each run adds distinct files, so conflicts are near-impossible). When the KB lives in the product repo, follow that repo's normal branch/PR rules instead — do not push to a protected main.
8. **Refresh the search index** if `knowledge-base.md` names one (e.g. `qmd update && qmd embed`). Best-effort — skip and say so if the tool isn't installed.
9. **Report** the file path and a one-line summary.

## Quality checklist

Before writing the file:

- [ ] Every section present (use "None" if empty)
- [ ] File paths in "What Changed" and "Files Affected" are accurate
- [ ] "Key Decisions" holds only non-obvious choices — nothing that passes the ADR test
- [ ] "Gotchas" would actually save someone debugging time
- [ ] Every "Deferred" item carries an issue reference or *(accept if forgotten)*
- [ ] No sentence restates what the code or file path already makes obvious
- [ ] The slug is descriptive and grep-friendly
