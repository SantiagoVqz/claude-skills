---
name: team-report
description: Team-facing status report rebuilt from ground truth — recent devnotes, merged + open PRs, open issues, and git log since a date — synthesized into a plain-language update you can paste to the team. Read-only. Triggers on "team report", "status report", "what shipped", "what's in flight", "weekly update".
---

# Team Report

Rebuild the "what's going on / what shipped" picture from **ground truth** — the devnotes knowledge base, PRs, issues, and git history — and synthesize a **team-facing report**.

This is a communication artifact, not an operations tool. It is not the source of deploy commands, and it does not decide what to work on next.

**Strictly read-only.** The only permitted writes are freshness refreshes: `git pull --ff-only` on the KB, `git fetch`, and the search-index refresh. Never merge, deploy, commit code, or mutate issues. The one exception is step 5, and only if the user says yes.

## 0. Read the repo's config

- **`docs/agents/knowledge-base.md`** — where devnotes live, how to refresh them, the index-refresh command, and **who reads this report**. The audience recorded there drives the voice in step 3.
- **`docs/agents/issue-tracker.md`** — which CLI (`gh`, `glab`, local markdown files, other) backs steps 2's PR and issue lookups.

If `knowledge-base.md` is absent, run without the devnote source: report from PRs, issues, and git log alone, and say at the top that the "why" behind changes is missing because no KB is configured.

## 1. Scope the window

Default: **since the date of the most recent team report**, else the last 7 days. If the user names a window ("this week", "since Monday", "since v1.2"), use it. State the window explicitly at the top of the report.

## 2. Gather ground truth

Refresh first (freshness only — still read-only), then gather in parallel.

```bash
git -C <kb-path> pull --ff-only    # other sessions/machines push devnotes to its main
git fetch origin --tags
<index-refresh>                     # e.g. qmd update && qmd embed — best-effort, note if absent
```

If a pull fails (diverged), report that in the output rather than resolving it here.

**Recent devnotes** — the primary "why / decisions / gotchas" source, and the reason this report beats reading PR titles. List by date, read the ones inside the window. For a topical report, also search the KB to pull relevant older context.

**Merged PRs in the window** — what actually shipped. **Open PRs** — in flight or awaiting review. **Open issues in progress** — what's queued (cross-reference, not source of truth). Use whichever CLI `issue-tracker.md` names, e.g.:

```bash
gh pr list --state merged --search "merged:>=YYYY-MM-DD" --json number,title,mergedAt,author,labels
gh pr list --state open --json number,title,headRefName,isDraft,reviewDecision,updatedAt
gh issue list --state open --json number,title,labels,assignees,updatedAt
```

**Git log since the window** — merge commits on the default branch, one line per landed PR:

```bash
git log --oneline --first-parent --since="YYYY-MM-DD" origin/<default-branch>
```

**Reconcile the sources.** A devnote describing work whose PR isn't merged yet is **in flight**, not shipped. A merged PR with no devnote is still shipped — include it, flagged "no devnote" so someone can backfill.

## 3. Synthesize

Write for the audience named in `knowledge-base.md`. For a mixed audience (non-technical stakeholders + engineers), which is the common case:

- Each **shipped** bullet opens with a plain-language sentence anyone understands, followed by a short *italic technical anchor* — issue/PR ref plus a one-clause mechanism. No shas, migration names, or internal component names in the plain part.
- **Fixes** use problem → fix shape ("X was broken, so we did Y"): one clause on what was wrong and its user-visible effect, then what changed. **Features** just say what they do.
- One bullet per user-visible change (lead with these), then at most one bullet bundling all invisible or internal items.
- Mention anything users might *notice* changing (relabeled screens, new flows) so support isn't surprised.
- Skip anything merged but inert (flagged off) — or mention it as "coming soon" only if asked.
- Short: one line per bullet, ~7 bullets max. A batch of 14 PRs is still one short message — group related work.
- Pull the **"why" and the decisions from the devnotes**, not just PR titles. That's the whole value of sourcing from the KB.

For an engineers-only audience, drop the plain-language-first rule and lead with the mechanism — but keep the length discipline.

## 4. Report shape — one screen

```
## <Project> — team update (<window>)

### Shipped
- <plain-language change users can understand>  _(#PR — one-clause mechanism)_
- <fix: what was wrong → what changed>  _(#PR)_
- Internal: <bundle of invisible changes>  _(#PR, #PR)_

### In flight
- <feature> — PR #N open (review: <state>), <issue #M in progress>
- <feature> — devnote written, PR not up yet

### Heads-up
- <anything support or users will notice, or a gotcha worth broadcasting>

### Needs backfill
- PR #N merged with no devnote — ask <author> to run /devnote
```

Omit any empty section. If a lookup fails (auth, rate limit, missing tool), report that section as UNKNOWN rather than dropping it silently — a missing section reads as "nothing happened".

## 5. Offer to save it

After presenting, offer to persist the report as a discussion-only devnote (`/devnote`, slug `team-report-YYYY-MM-DD`) so the next run's window anchors off it. Write only if the user says yes — this skill stays read-only by default.
