---
name: retro
description: "Review a session in which skills ran, and log what each skill did wrong with evidence and a proposed fix."
disable-model-invocation: true
argument-hint: "[transcript path]"
---

# Retro

The skill set improves from evidence, not from memory. `/retro` reads the session transcript, compares what each skill did with what its `SKILL.md` says, and writes the gaps to a run file. It proposes fixes and edits no skill.

## 1. Read the session

Run `python3 -I <this skill's folder>/digest.py [transcript]`. With no argument, it reads the current session. The output is a timeline: user messages, commands, skills, subagents, questions and tool errors, each with its transcript line number. Open the transcript at a line when you need the full text.

Completion: you can list each skill that ran in the session.

## 2. Find the run folder

Resolve this `SKILL.md` with `realpath`. When it is in a git repo other than the current project, that repo is the skills repo, and the run folder is `runs/` at its root. When it is not, the run folder is `.scratch/retro/` in the project. Tell the user to send the file to the owner of the skill set.

Completion: you know the run folder.

## 3. Read earlier runs

Read the findings in the run folder about the skills from step 1. Note each finding that is `open` and each that is `rejected`.

Completion: you have the open and rejected findings for each skill that ran.

## 4. Find the gaps

Read the `SKILL.md` of each skill that ran. Then go through the timeline and look for:

- **Skipped step**: a step that did not run, or a completion criterion that the agent claimed but did not meet.
- **Correction**: the user corrected, repeated or stopped the agent.
- **Wrong trigger**: a skill fired when it should not, or did not fire when it should.
- **Fact question**: the agent asked the user for a fact that it could look up.
- **Excuse**: the agent gave a reason to skip work. These become anti-rationalization rows.
- **Friction**: a tool error, a retry, or a long detour.

For each gap, decide the fix: sharpen the wording, add a step, add a row to an anti-rationalization table, cut a no-op, or change a description. A gap that is caused by the project and not by a skill gets the `project` tag and no fix.

When a gap matches an open finding from step 3, link that finding and count the runs. When it matches a rejected finding, leave it out.

Completion: each gap has a skill and step, evidence with a transcript line number, and a fix or the `project` tag.

## 5. Confirm and write

Show the findings to the user, ordered by how many runs saw them, then by cost to the user. The user can drop or change each one. Then write `<run folder>/<date>-<project>-<skills>.md` in this format:

```markdown
# <date> · <project> · <skills that ran>

Transcript: <path>

<One or two sentences: what the session did.>

## Findings

### F1 · <skill> · step <n> · <short title>

Status: open
Seen in: <earlier run file and finding number, with the count, or "first time">
What happened: <one or two sentences>
Evidence: line <n>: "<quote>"
Fix: <fix type>: <the change to make>

## Worked

- <a skill step that did what it should, worth keeping as it is>
```

A finding's ID is its file name and number, for example `2026-10-15-habits-spec#F1`. The commit that applies a fix names that ID in its message and sets `Status: applied` in the same change. `git log --grep <ID>` then finds the fix. When we decide against a fix, set `Status: rejected: <reason>`.

Completion: the run file exists, and the user approved its findings.

## Report

Run file path · findings: new, repeated, project · the finding to fix first.
