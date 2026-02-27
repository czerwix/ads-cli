# sgd - Search Google Docs

`sgd` is a Swift CLI for searching Android, Kotlin, and Jetpack documentation.

## Install

```bash
swift build -c release
.build/release/sgd --help
```

## Commands

- `sgd search <query> [--limit N] [--json]`
- `sgd doc <path-or-url> [--json]`
- `sgd related <path-or-url> [--json]`
- `sgd platform <path-or-url> [--json]`
- `sgd frameworks [--filter text] [--json]`

Markdown is default output. Use `--json` for machine-readable output.

## AI Agent Usage

Use JSON mode for deterministic parsing:

```bash
sgd search "viewmodel" --limit 5 --json
sgd doc "topic/libraries/architecture/viewmodel" --json
```

## Development

```bash
swift test
```
