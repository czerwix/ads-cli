---
name: ads-docs-cli
description: Use when users need Android, Kotlin, or Jetpack documentation lookup from terminal commands. Trigger this skill for Google docs search, topic path or URL resolution, related or platform metadata lookup, source or kind filtering, official-only filtering, and JSON-first outputs for automation or agent workflows.
---

# ads Docs Skill

Use `ads` for deterministic Android/Kotlin/Jetpack docs retrieval.

Default to `--json` when the result will be parsed, transformed, compared, or used by another tool.

## When To Use

- User asks for Android, Kotlin, Jetpack, or Google developer docs lookup.
- User needs a topic resolved from a path or URL.
- User asks for related topics or platform metadata.
- User needs scriptable output for automation (`--json`).
- User wants source/kind constrained results (`android`, `guide`, etc.).

## When Not To Use

- General web browsing outside Android/Kotlin/Jetpack docs.
- Tasks that do not require documentation retrieval.
- Pure prose rewriting tasks with no docs lookup step.

## Fast Path Workflow (Agent Default)

1. Discover valid sources and kinds:
   - `ads sources --json`
2. Search candidates:
   - `ads search "<query>" --json`
3. Narrow if needed:
   - `ads search "<query>" --source android --json`
   - `ads search "<query>" --kind guide --json`
4. Resolve one result:
   - `ads doc "<path-or-url>" --json`
5. Expand context if needed:
   - `ads related "<path-or-url>" --json`
   - `ads platform "<path-or-url>" --json`

## Usage Scenarios And Examples

### `search`

Basic search:

```bash
ads search "viewmodel"
```

Limit results:

```bash
ads search "viewmodel" --limit 5
```

Filter by source:

```bash
ads search "navigation" --source android
```

Filter by kind:

```bash
ads search "navigation" --kind guide
```

Official docs only:

```bash
ads search "compose state" --official-only
```

Include non-official results:

```bash
ads search "compose state" --no-official-only
```

Automation-ready search:

```bash
ads search "navigation" --source android --kind guide --limit 5 --json
```

### `sources`

List sources in Markdown:

```bash
ads sources
```

List sources in JSON (recommended for agents):

```bash
ads sources --json
```

### `doc`

Resolve by topic path:

```bash
ads doc "topic/libraries/architecture/viewmodel"
```

Resolve by full URL:

```bash
ads doc "https://developer.android.com/topic/libraries/architecture/viewmodel"
```

JSON output for deterministic parsing:

```bash
ads doc "topic/libraries/architecture/viewmodel" --json
```

### `related`

Related topics from topic path:

```bash
ads related "topic/libraries/architecture/viewmodel"
```

Related topics from URL:

```bash
ads related "https://developer.android.com/topic/libraries/architecture/viewmodel"
```

JSON output:

```bash
ads related "topic/libraries/architecture/viewmodel" --json
```

### `platform`

Platform metadata from topic path:

```bash
ads platform "topic/libraries/architecture/viewmodel"
```

Platform metadata from URL:

```bash
ads platform "https://developer.android.com/topic/libraries/architecture/viewmodel"
```

JSON output:

```bash
ads platform "topic/libraries/architecture/viewmodel" --json
```

### `frameworks`

List frameworks:

```bash
ads frameworks
```

Filter frameworks:

```bash
ads frameworks --filter compose
```

JSON output:

```bash
ads frameworks --json
```

## Command Intent Matrix

| Intent | Command |
| --- | --- |
| Discover available sources/kinds | `ads sources --json` |
| Find relevant docs | `ads search "<query>" --json` |
| Fetch one doc page | `ads doc "<path-or-url>" --json` |
| Get related reading | `ads related "<path-or-url>" --json` |
| Get platform metadata | `ads platform "<path-or-url>" --json` |
| List framework categories | `ads frameworks --json` |

## Output Mode Rules

- Use Markdown output when the user wants readable terminal output.
- Use JSON output when the result is consumed by an agent, script, or downstream tool.
- In automation flows, keep all steps in JSON (`sources`, `search`, `doc`, `related`, `platform`, `frameworks`).

## Recovery Rules

- Results too broad: add `--source` and/or `--kind`, then reduce with `--limit`.
- Unknown source IDs: call `ads sources --json` before retrying search.
- Path fails in `doc`: retry with the full URL form.
- Too few results: relax one filter (`--kind` first, then `--source`) and retry.
- Need broader context: follow `doc` with `related` and `platform`.

## Common Mistakes

- Skipping `ads sources --json` and guessing source IDs.
- Forgetting `--json` in agent automation workflows.
- Forgetting `--official-only` or `--no-official-only` when source quality scope matters.
- Running `doc` before narrowing search results.

For install details by runner, see `docs/ai-skill.md`.
