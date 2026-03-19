# Claude Skills

Personal collection of reusable Claude Code skills.

## Skills

### GitHub
| Skill | Description |
|-------|-------------|
| `github/create-issue` | Create GitHub issues with INVEST compliance, labels, milestones, and project board assignment |

### Jira
| Skill | Description |
|-------|-------------|
| `jira/jira-epic-import` | Interactive feature planning (interview → Epic/Stories → Jira) |
| `jira/gsd-jira-sync` | Sync GSD planning phases to Jira as Epics and Stories |

### Planning
| Skill | Description |
|-------|-------------|
| `planning/plan-to-issues` | Convert GSD phase plans into GitHub or Jira issues |

### Quality
| Skill | Description |
|-------|-------------|
| `verify` | Generate concise E2E verification steps after plan execution to confirm changes work |

## Installation

### Install a skill globally (all projects)

```bash
./install.sh <category/skill-name> --global
# Example: ./install.sh jira/jira-epic-import --global
```

### Install a skill into the current project

```bash
./install.sh <category/skill-name>
# Example: ./install.sh github/create-issue
```

### Install all skills globally

```bash
./install.sh --all --global
```

### Manual installation

```bash
# Global
cp -r <category>/<skill-name> ~/.claude/skills/<skill-name>

# Project
cp -r <category>/<skill-name> .claude/skills/<skill-name>
```
