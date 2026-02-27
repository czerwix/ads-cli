# ads

Search Android, Kotlin, and Jetpack documentation from the terminal.

`ads` is the Google-docs companion to `sad-cli`, focused on fast search, doc retrieval, and machine-readable output for automation.

## Install

Build from source (Swift 6, macOS 13+):

```bash
swift build -c release
```

The binary will be available at:

```bash
.build/release/ads
```

Optional local sanity check:

```bash
.build/release/ads --help
```

## Build And Run

Run without creating a release build:

```bash
swift run ads --help
```

Run a command with the release binary:

```bash
.build/release/ads search "compose"
```

## Command Surface

- `ads search <query> [--limit N] [--json]`
- `ads doc <path-or-url> [--json]`
- `ads related <path-or-url> [--json]`
- `ads platform <path-or-url> [--json]`
- `ads frameworks [--filter text] [--json]`

By default, commands print Markdown. Use `--json` for structured output.

## Human CLI Usage

Search documentation across Android, Kotlin, and Jetpack providers:

```bash
ads search "viewmodel" --limit 5
```

Retrieve a document by topic path or full URL:

```bash
ads doc "topic/libraries/architecture/viewmodel"
```

Show related topics for a page:

```bash
ads related "topic/libraries/architecture/viewmodel"
```

Show platform metadata for a page:

```bash
ads platform "topic/libraries/architecture/viewmodel"
```

List framework categories (optionally filtered):

```bash
ads frameworks --filter compose
```

## AI-Agent Usage

Use JSON mode for deterministic parsing in agent workflows:

```bash
ads search "viewmodel" --limit 5 --json
ads doc "topic/libraries/architecture/viewmodel" --json
ads related "topic/libraries/architecture/viewmodel" --json
ads platform "topic/libraries/architecture/viewmodel" --json
ads frameworks --json
```

Recommended pattern for agents:

1. call `search` to discover candidate pages,
2. resolve one page with `doc`,
3. expand context via `related` or `platform` as needed.

## Scope And Direction

Current behavior:

- `search` fans out across Android, Kotlin, and Jetpack providers.
- `doc`, `related`, and `platform` currently resolve content via the Android docs provider.
- `frameworks` returns a local framework catalog and supports Markdown/JSON output.

Planned expansion (not fully implemented yet):

- add provider-aware document resolution parity for Kotlin and Jetpack in `doc`/`related`/`platform`,
- improve unified ranking and source attribution across providers,
- harden output contracts for deeper agent integrations.

## Development

```bash
swift test
```
