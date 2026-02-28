# AI Skill Setup

Install the custom `ads-docs-cli` skill from this repository for OpenCode, Claude Code, or Codex CLI.

The skill is tuned for Android, Kotlin, Jetpack, Firebase, Google Play Services, and Material docs workflows.

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

Add the contents of `skill/SKILL.md` to your Codex system prompt or project instructions file.

Quick copy command:

```bash
pbcopy < skill/SKILL.md
```

Then paste into your Codex instruction surface.

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

Re-copy `skill/SKILL.md` and replace the existing instructions in Codex.

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

Remove the skill text from your Codex system prompt or project instructions file.

## Use With `ads`

Use JSON output for stable parsing:

```bash
ads sources --json
ads search "viewmodel" --json
ads search "viewmodel" --source android --json
ads search "viewmodel" --kind reference --json
ads search "navigation" --kind guide --json
ads doc "topic/libraries/architecture/viewmodel" --json
ads related "topic/libraries/architecture/viewmodel" --json
ads platform "topic/libraries/architecture/viewmodel" --json
ads frameworks --json
```

For `v0.1.3`, remember:

- `search` re-ranks by query relevance and deduplicates canonical URLs before limit.
- `viewmodel` can return canonical Android fallback results when strict provider parsing yields none.
- `sources --json` now includes relevance metadata fields (`preferredPathPrefixes`, `blockedTitlePhrases`, `blockedURLFragments`).

Suggested command flow:

1. `sources` to confirm valid source IDs and kinds.
2. `search` to gather candidates.
3. `doc` for the chosen page.
4. `related` and `platform` for context expansion.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `cp: skill/SKILL.md: No such file` | Run commands from repo root or replace with absolute path. |
| `pbcopy: command not found` | Use `cat skill/SKILL.md` and copy manually, or use another clipboard tool. |
| Skill not appearing in runner | Restart the runner session after install. |
| Wrong directory path used | Re-run install with the exact path for your runner above. |
