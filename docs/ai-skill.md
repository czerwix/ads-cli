# AI Skill Setup

Install the custom `ads-docs-cli` skill from this repository for OpenCode, Claude Code, or Codex CLI.

Skill source file:

`skill/SKILL.md`

## Prerequisites

Run commands from the repository root (`ads-cli`), so `skill/SKILL.md` resolves correctly.

## Install

### OpenCode

Install:

```bash
mkdir -p ~/.config/opencode/skills/ads-docs-cli
cp skill/SKILL.md ~/.config/opencode/skills/ads-docs-cli/SKILL.md
```

Verify:

```bash
ls -l ~/.config/opencode/skills/ads-docs-cli
```

### Claude Code

Install:

```bash
mkdir -p ~/.claude/skills/ads-docs-cli
cp skill/SKILL.md ~/.claude/skills/ads-docs-cli/SKILL.md
```

Verify:

```bash
ls -l ~/.claude/skills/ads-docs-cli
```

### Codex CLI

Install:

```bash
mkdir -p ~/.agents/skills/ads-docs-cli
cp skill/SKILL.md ~/.agents/skills/ads-docs-cli/SKILL.md
```

Verify:

```bash
ls -l ~/.agents/skills/ads-docs-cli
```

## Update Or Reinstall

Re-copy the skill file to your runner directory.

OpenCode

```bash
cp skill/SKILL.md ~/.config/opencode/skills/ads-docs-cli/SKILL.md
```

Claude Code

```bash
cp skill/SKILL.md ~/.claude/skills/ads-docs-cli/SKILL.md
```

Codex CLI

```bash
cp skill/SKILL.md ~/.agents/skills/ads-docs-cli/SKILL.md
```

## Uninstall

OpenCode

```bash
rm -rf ~/.config/opencode/skills/ads-docs-cli
```

Claude Code

```bash
rm -rf ~/.claude/skills/ads-docs-cli
```

Codex CLI

```bash
rm -rf ~/.agents/skills/ads-docs-cli
```

## Use With `ads`

Use JSON output for stable parsing:

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

Suggested command flow:

1. `sources` to confirm valid source IDs and kinds.
2. `search` to gather candidates.
3. `doc` for the chosen page.
4. `related` and `platform` for context expansion.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `cp: skill/SKILL.md: No such file` | Run commands from repo root or replace with absolute path. |
| Skill not appearing in runner | Restart the runner session after install. |
| Wrong directory path used | Re-run install with the exact path for your runner above. |
