---
name: ads-docs-cli
description: Use when users need Android, Kotlin, or Jetpack documentation through terminal commands, especially for Google docs search, topic path or URL resolution, related/platform metadata lookup, source or kind filtering, and JSON-first outputs for automation or agent workflows.
---

# ads Docs Skill

Use `ads` for deterministic Android docs retrieval. Default to JSON output for stable parsing.

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

## Fast Path Workflow

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

## Command Intent Matrix

| Intent | Command |
| --- | --- |
| Discover available sources/kinds | `ads sources --json` |
| Find relevant docs | `ads search "<query>" --json` |
| Fetch one doc page | `ads doc "<path-or-url>" --json` |
| Get related reading | `ads related "<path-or-url>" --json` |
| Get platform metadata | `ads platform "<path-or-url>" --json` |
| List framework categories | `ads frameworks --json` |

## Recovery Rules

- Results too broad: add `--source` and/or `--kind`, then reduce with `--limit`.
- Unknown source IDs: call `ads sources --json` before retrying search.
- Path fails in `doc`: retry with the full URL form.
- Need broader context: follow `doc` with `related` and `platform`.

## Common Mistakes

- Skipping `ads sources --json` and guessing source IDs.
- Forgetting `--json` in agent automation workflows.
- Running `doc` before narrowing search results.

For install details by runner, see `docs/ai-skill.md`.
