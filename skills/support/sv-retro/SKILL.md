---
name: sv-retro
description: "Review the sessions since the last retro in which skills ran, and log what each skill did wrong with evidence and a proposed fix."
disable-model-invocation: true
argument-hint: "[--since YYYY-MM-DD]"
---

# Retro

The skill set improves from evidence, not from memory. `/sv-retro` reads each session since the last retro, in each project, compares what each skill did with what its `SKILL.md` says, and writes the gaps to one run file. It proposes fixes and edits no skill.

`digest.py` is in the folder of this skill. Run it with `python3 -I`.

## 1. Find the run folder

Resolve this `SKILL.md` with `realpath`. Walk up from that path, and look for a `.git` folder with `ls`. Run no git command on that path, because the worktree guard refuses it. When you find a repo other than the current project, that repo is the skills repo, and the run folder is `runs/` at its root. When you do not, the run folder is `.scratch/retro/` in the project. Tell the user to send the file to the owner of the skill set.

Completion: you know the run folder.

## 2. List the sessions

Run `digest.py --list --runs <run folder>`, with `--since <date>` when the user gave one. It prints one row for each session in which a skill of this set ran, after the lines that a run file already covers:

```text
<session> · <project> · <skills> · lines <first>-<last> · <transcript path>
```

With no row, tell the user that no session needs a retro, and stop.

Completion: you have the sessions, each with its line range.

## 3. Read the sessions

For one or two sessions, read each one yourself: run `digest.py <transcript> --from <first>`. The output is a timeline: user messages, commands, skills, subagents, questions and tool errors, each with its transcript line number. Open the transcript at a line when you need the full text. Then find the gaps as step 5 says.

For three sessions or more, start one subagent for each session, all at once. Give each one its row, the path of this `SKILL.md`, and this task: read the timeline, read the `SKILL.md` of each skill that ran, find the gaps as step 5 says, and return each gap in the finding format of step 6, with no status. Evidence cites `<session>:<line>`.

Completion: you have the gaps of each session.

## 4. Read earlier runs

Read the findings in the run folder about the skills that ran. Note each finding that is `open` and each that is `rejected`.

Completion: you have the open and rejected findings for each skill that ran.

## 5. Find and merge the gaps

Look for these gaps in each timeline:

- **Skipped step**: a step that did not run, or a completion criterion that the agent claimed but did not meet.
- **Correction**: the user corrected, repeated or stopped the agent.
- **Wrong trigger**: a skill fired when it should not, or did not fire when it should.
- **Fact question**: the agent asked the user for a fact that it could look up.
- **Excuse**: the agent gave a reason to skip work. These become anti-rationalization rows.
- **Friction**: a tool error, a retry, or a long detour.
- **Outside skill**: a skill or agent that is not in this set ran. Record what it did that the set did not do.

For each gap, decide the fix: sharpen the wording, add a step, add a row to an anti-rationalization table, cut a no-op, change a description, or, for an outside skill, add its idea to an `sv-` skill or propose a new skill. A gap that is caused by the project and not by a skill gets the `project` tag and no fix.

Merge the gaps of all sessions. The same gap in more than one session is one finding, with evidence from each session. When a gap matches an open finding from step 4, link that finding and count the runs. When it matches a rejected finding, leave it out.

Completion: each finding has a skill and step, evidence with `<session>:<line>`, and a fix or the `project` tag.

## 6. Confirm and write

Show the findings to the user, ordered by how many sessions and runs saw them, then by cost to the user. The user can drop or change each one. Then write `<run folder>/<date>-<projects>-<skills>.md` in this format:

```markdown
# <date> · <projects> · <skills that ran>

<One or two sentences: what the sessions did.>

## Sessions

- <transcript path> · lines <first>-<last>

## Findings

### F1 · <skill> · step <n> · <short title>

Status: open
Seen in: <the sessions of this retro, and each earlier run file and finding number, with the count, or "first time">
What happened: <one or two sentences>
Evidence: <session>:<line>: "<quote>"
Fix: <fix type>: <the change to make>

## Worked

- <a skill step that did what it should, worth keeping as it is>
```

The Sessions list is the coverage record: the next `/sv-retro` starts each transcript after its last line. Write each row from step 2, with the path in full and the range unchanged.

A finding's ID is its file name and number, for example `2026-10-15-habits-spec#F1`. The commit that applies a fix names that ID in its message and sets `Status: applied` in the same change. `git log --grep <ID>` then finds the fix. When we decide against a fix, set `Status: rejected: <reason>`.

Completion: the run file exists, its Sessions list has each row from step 2, and the user approved its findings.

## Report

Run file path · sessions read · findings: new, repeated, project · the finding to fix first.
