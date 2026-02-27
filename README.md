# ads

Search Android, Kotlin, and Jetpack documentation from the terminal.

Fast docs lookup, clean output, and JSON for automation.

## Contents

- [Quick Start](#quick-start)
- [Build and Run](#build-and-run)
- [Command Reference](#command-reference)
- [Human CLI Usage](#human-cli-usage)
- [AI Agent Usage](#ai-agent-usage)
- [AI Skill](#ai-skill)
- [Scope and Direction](#scope-and-direction)
- [Development](#development)
- [Release Docs](#release-docs)

## Quick Start

| Task | Command |
| --- | --- |
| Install with Homebrew | `brew tap skraus/tap`<br>`brew install ads-cli` |
| Upgrade | `brew upgrade ads-cli` |
| Build from source (Swift 6, macOS 13+) | `swift build -c release` |
| Show help | `.build/release/ads --help` |

Built binary: `.build/release/ads`

## Build and Run

| Mode | Command |
| --- | --- |
| Run without a release build | `swift run ads --help` |
| Run with the release binary | `.build/release/ads search "compose"` |

## Command Reference

| Command | What it does |
| --- | --- |
| `ads search <query> [--limit N] [--source id] [--kind kind] [--[no-]official-only] [--json]` | Search docs across providers |
| `ads sources [--json]` | List supported sources and metadata |
| `ads doc <path-or-url> [--json]` | Fetch one document |
| `ads related <path-or-url> [--json]` | Show related topics for a page |
| `ads platform <path-or-url> [--json]` | Show page platform metadata |
| `ads frameworks [--filter text] [--json]` | List framework categories |

Default output is Markdown. Add `--json` for structured output.

---

## Human CLI Usage

| Goal | Example |
| --- | --- |
| Search docs | `ads search "viewmodel" --limit 5`<br>`ads search "navigation" --source android --kind guide` |
| List sources | `ads sources` |
| Open one document | `ads doc "topic/libraries/architecture/viewmodel"` |
| Show related topics | `ads related "topic/libraries/architecture/viewmodel"` |
| Show platform metadata | `ads platform "topic/libraries/architecture/viewmodel"` |
| Filter framework list | `ads frameworks --filter compose` |

## AI Agent Usage

> [!TIP]
> Use `--json` for deterministic parsing.

```bash
ads search "viewmodel" --limit 5 --json
ads search "viewmodel" --source android --json
ads search "navigation" --kind guide --json
ads sources --json
ads doc "topic/libraries/architecture/viewmodel" --json
ads related "topic/libraries/architecture/viewmodel" --json
ads platform "topic/libraries/architecture/viewmodel" --json
ads frameworks --json
```

Recommended flow for agents:

1. Run `search` to find candidate pages.
2. Resolve one page with `doc`.
3. Expand context with `related` or `platform`.

---

## AI Skill

Agent-ready references:

- `skill/SKILL.md`
- `docs/ai-skill.md`

Quick setup:

1. Install the skill for your runner (OpenCode, Claude Code, or Codex CLI).
2. Prefer `ads ... --json` in automation.
3. Use `ads sources --json` before adding `search` filters.

## Scope and Direction

Current behavior:

- `search` fans out across Android, Kotlin, and Jetpack providers.
- `doc`, `related`, and `platform` currently resolve content via the Android docs provider.
- `frameworks` returns a local framework catalog in Markdown or JSON.

Planned expansion (not fully implemented yet):

- add provider-aware document resolution parity for Kotlin and Jetpack in `doc`/`related`/`platform`,
- improve unified ranking and source attribution across providers,
- harden output contracts for deeper agent integrations.

---

## Development

```bash
swift test
```

## Release Docs

| Document | Purpose |
| --- | --- |
| `docs/release-homebrew.md` | Primary release guide |
| `docs/plans/2026-02-27-homebrew-release-runbook.md` | Step-by-step release checklist |
