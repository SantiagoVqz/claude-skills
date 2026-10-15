#!/usr/bin/env python3
"""Print a short timeline of a Claude Code session transcript for /retro.

Usage: digest.py [transcript.jsonl]
With no argument, it reads the newest transcript of the current directory.
Each line starts with the transcript line number, so a finding can cite it.
"""
import json
import os
import re
import sys
from pathlib import Path

TEXT_MAX = 400
ERROR_MAX = 240


def default_transcript() -> Path:
    # Claude Code names the project folder after the cwd, with each non-alphanumeric character as "-".
    folder = Path.home() / ".claude" / "projects" / re.sub(r"[^A-Za-z0-9]", "-", os.getcwd())
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


def main() -> None:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else default_transcript()
    print(f"transcript {path}")
    tool_names = {}
    for n, line in enumerate(path.open(encoding="utf-8"), start=1):
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue
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
                    print(f"{n} {side}SUBAGENT {short(tool_input.get('description', ''), TEXT_MAX)}")
                elif block.get("name") == "AskUserQuestion":
                    print(f"{n} {side}ASK {short(json.dumps(tool_input.get('questions', '')), TEXT_MAX)}")
            elif btype == "tool_result" and block.get("is_error"):
                name = tool_names.get(block.get("tool_use_id"), "tool")
                print(f"{n} {side}ERROR {name} {short(result_text(block), ERROR_MAX)}")


if __name__ == "__main__":
    main()
