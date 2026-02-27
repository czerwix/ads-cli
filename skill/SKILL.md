---
name: ads-docs-cli
description: Use when an AI agent needs deterministic Android and Kotlin docs lookup from terminal commands.
---

# ads Docs Skill

Use `ads` as a JSON-first docs retrieval tool.

## Preferred Workflow

1. Discover available providers: `ads sources --json`
2. Find candidates: `ads search "<query>" --json`
3. Narrow by source or kind when needed:
   - `ads search "<query>" --source android --json`
   - `ads search "<query>" --kind guide --json`
4. Expand one result:
   - `ads doc "<path-or-url>" --json`
   - `ads related "<path-or-url>" --json`
   - `ads platform "<path-or-url>" --json`
5. Enumerate framework categories: `ads frameworks --json`

## Commands

- `search`: multi-source search (supports `--source`, `--kind`, `--json`)
- `sources`: source registry and metadata
- `doc`: page extraction by topic path or URL
- `related`: related topics for a page
- `platform`: platform metadata for a page
- `frameworks`: framework category listing

For install details by runner, see `docs/ai-skill.md`.
