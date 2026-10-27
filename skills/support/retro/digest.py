#!/usr/bin/env python3
"""Print a short timeline of a Claude Code session transcript, or list the sessions to review, for /retro.

Usage:
  digest.py [transcript.jsonl] [--from LINE]
  digest.py --list --runs RUN_FOLDER [--since YYYY-MM-DD]

With no transcript, it reads the newest transcript of the current directory.
Each timeline line starts with the transcript line number, so a finding can cite it.
--list prints one row for each session where a skill of this set ran in the lines that no run file covers.
"""
import argparse
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path

TEXT_MAX = 400
ERROR_MAX = 240
PROJECTS = Path.home() / ".claude" / "projects"
# A run file records coverage as "- <transcript path> · lines <first>-<last>" under "## Sessions".
SESSION_ROW = re.compile(r"^- (\S+\.jsonl) · lines (\d+)-(\d+)", re.M)
RUN_DATE = re.compile(r"^(\d{4}-\d{2}-\d{2})-")


def default_transcript() -> Path:
    # Claude Code names the project folder after the cwd, with each non-alphanumeric character as "-".
    folder = PROJECTS / re.sub(r"[^A-Za-z0-9]", "-", os.getcwd())
    files = sorted(folder.glob("*.jsonl"), key=lambda p: p.stat().st_mtime)
    if not files:
        sys.exit(f"no transcript in {folder}")
    return files[-1]


def short(text: str, limit: int) -> str:
    text = " ".join(str(text).split())
    return text if len(text) <= limit else text[:limit] + " …"


def result_text(block: dict) -> str:
    content = block.get("content")
    if isinstance(content, list):
        return " ".join(b.get("text", "") for b in content if isinstance(b, dict))
    return str(content or "")


def entries(path: Path, start: int = 1):
    for n, line in enumerate(path.open(encoding="utf-8"), start=1):
        if n < start:
            continue
        try:
            yield n, json.loads(line)
        except json.JSONDecodeError:
            continue


def timeline(path: Path, start: int) -> None:
    print(f"transcript {path}")
    tool_names = {}
    for n, entry in entries(path, start):
        kind = entry.get("type")
        if kind not in ("user", "assistant") or entry.get("isMeta"):
            continue
        side = "sub " if entry.get("isSidechain") else ""
        content = (entry.get("message") or {}).get("content")
        if isinstance(content, str):
            command = re.search(r"<command-name>(.*?)</command-name>", content)
            if command:
                args = re.search(r"<command-args>(.*?)</command-args>", content, re.S)
                print(f"{n} {side}COMMAND {command.group(1)} {short(args.group(1) if args else '', TEXT_MAX)}")
            elif kind == "user":
                print(f"{n} {side}USER {short(content, TEXT_MAX)}")
            continue
        for block in content or []:
            btype = block.get("type")
            if btype == "text" and kind == "assistant":
                print(f"{n} {side}AGENT {short(block['text'], TEXT_MAX)}")
            elif btype == "text" and kind == "user":
                print(f"{n} {side}USER {short(block['text'], TEXT_MAX)}")
            elif btype == "tool_use":
                tool_names[block.get("id")] = block.get("name")
                tool_input = block.get("input") or {}
                if block.get("name") == "Skill":
                    print(f"{n} {side}SKILL {tool_input.get('skill')} {short(tool_input.get('args', ''), TEXT_MAX)}")
                elif block.get("name") in ("Agent", "Task"):
                    kind_name = tool_input.get("subagent_type") or "general"
                    print(f"{n} {side}SUBAGENT {kind_name} {short(tool_input.get('description', ''), TEXT_MAX)}")
                elif block.get("name") == "AskUserQuestion":
                    print(f"{n} {side}ASK {short(json.dumps(tool_input.get('questions', '')), TEXT_MAX)}")
            elif btype == "tool_result" and block.get("is_error"):
                name = tool_names.get(block.get("tool_use_id"), "tool")
                print(f"{n} {side}ERROR {name} {short(result_text(block), ERROR_MAX)}")


def skills_repo() -> Path:
    # The skills repo is the first folder above this script that has .git.
    here = Path(__file__).resolve()
    for folder in here.parents:
        if (folder / ".git").exists():
            return folder
    sys.exit(f"no skills repo above {here}")


def coverage(runs: Path):
    covered, newest = {}, None
    for run in runs.glob("*.md"):
        date = RUN_DATE.match(run.name)
        if date and (newest is None or date.group(1) > newest):
            newest = date.group(1)
        for path, _, last in SESSION_ROW.findall(run.read_text(encoding="utf-8")):
            key = str(Path(path).expanduser())
            covered[key] = max(covered.get(key, 0), int(last))
    return covered, newest


def skills_run(path: Path, start: int, names: set):
    found, cwd, last = [], None, start - 1
    for n, entry in entries(path, start):
        last = n
        cwd = cwd or entry.get("cwd")
        content = (entry.get("message") or {}).get("content")
        if isinstance(content, str):
            command = re.search(r"<command-name>/?(.*?)</command-name>", content)
            hits = [command.group(1)] if command else []
        else:
            hits = [
                (b.get("input") or {}).get("skill", "")
                for b in content or []
                if isinstance(b, dict) and b.get("type") == "tool_use" and b.get("name") == "Skill"
            ]
        for hit in hits:
            if hit in names and hit not in found:
                found.append(hit)
    return found, cwd, last


def list_sessions(runs: Path, since: "str | None") -> None:
    covered, newest = coverage(runs)
    since = since or newest
    floor = datetime.fromisoformat(since).timestamp() if since else 0
    repo = skills_repo()
    names = {p.parent.name for p in (repo / "skills").rglob("SKILL.md")}
    print(f"since {since or 'the start'} · runs {runs}")
    for path in sorted(PROJECTS.glob("*/*.jsonl"), key=lambda p: p.stat().st_mtime):
        if path.stat().st_mtime < floor:
            continue
        start = covered.get(str(path), 0) + 1
        found, cwd, last = skills_run(path, start, names)
        # A session in the skills repo edits the set; it is not a run of it.
        if not found or (cwd or "").startswith(str(repo)):
            continue
        # A worktree cwd is <repo>/.claude/worktrees/<branch>; name the project after the repo.
        project = Path((cwd or "").split("/.claude/worktrees/")[0]).name or path.parent.name
        print(f"{path.stem[:8]} · {project} · {', '.join(found)} · lines {start}-{last} · {path}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("transcript", nargs="?")
    parser.add_argument("--from", dest="start", type=int, default=1)
    parser.add_argument("--list", action="store_true")
    parser.add_argument("--runs")
    parser.add_argument("--since")
    args = parser.parse_args()
    if args.list:
        if not args.runs:
            sys.exit("--list needs --runs")
        list_sessions(Path(args.runs).expanduser(), args.since)
    else:
        timeline(Path(args.transcript) if args.transcript else default_transcript(), args.start)


if __name__ == "__main__":
    main()
