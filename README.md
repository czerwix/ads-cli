# ads - Search Google Docs

`ads` is a Swift CLI for searching Android, Kotlin, and Jetpack documentation.

## Install

```bash
swift build -c release
.build/release/ads --help
```

## Commands

- `ads search <query> [--limit N] [--json]`
- `ads doc <path-or-url> [--json]`
- `ads related <path-or-url> [--json]`
- `ads platform <path-or-url> [--json]`
- `ads frameworks [--filter text] [--json]`

Markdown is default output. Use `--json` for machine-readable output.

## AI Agent Usage

Use JSON mode for deterministic parsing:

```bash
ads search "viewmodel" --limit 5 --json
ads doc "topic/libraries/architecture/viewmodel" --json
```

## Development

```bash
swift test
```
