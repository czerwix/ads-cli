# AI Skill Setup

This repo ships an AI skill at `skill/SKILL.md` for JSON-first usage of `ads`.

## Install

OpenCode:

```bash
mkdir -p ~/.config/opencode/skills/ads-docs-cli
cp skill/SKILL.md ~/.config/opencode/skills/ads-docs-cli/SKILL.md
```

Claude Code:

```bash
mkdir -p ~/.claude/skills/ads-docs-cli
cp skill/SKILL.md ~/.claude/skills/ads-docs-cli/SKILL.md
```

Codex CLI:

```bash
mkdir -p ~/.agents/skills/ads-docs-cli
cp skill/SKILL.md ~/.agents/skills/ads-docs-cli/SKILL.md
```

## Use

Prefer machine-readable output:

```bash
ads sources --json
ads search "viewmodel" --json
ads search "viewmodel" --source android --json
ads search "navigation" --kind guide --json
ads doc "topic/libraries/architecture/viewmodel" --json
ads related "topic/libraries/architecture/viewmodel" --json
ads platform "topic/libraries/architecture/viewmodel" --json
ads frameworks --json
```

Recommended agent sequence:

1. `sources` to confirm valid source IDs and kinds.
2. `search` to gather candidates (with `--source`/`--kind` as needed).
3. `doc` for the selected page, then `related` and `platform` for context.
