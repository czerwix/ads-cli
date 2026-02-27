# Decisions

## Purpose
Record key project decisions made as planning defaults.

## Core Decisions Made Without Direct User Input

1. **CLI working name:** `sgd` (Search Google Docs).
   - Rationale: short name and close to `sad` naming style.
2. **Project shape:** thin executable + library module split.
   - `Sources/sgd/` contains CLI entrypoint.
   - `Sources/GoogleDocsLib/` contains commands, providers, parsing, networking, and models.
3. **Provider adapter model:** one adapter per source (`AndroidDocsProvider`, `KotlinDocsProvider`, `JetpackDocsProvider`).
4. **Output contract:** Markdown by default and structured JSON with `--json`.
5. **v1 command surface:** `search`, `doc`, `frameworks`, `related`, `platform`.
6. **Runtime policy:** stateless in v1 (no local DB, no auth, no setup flow).
7. **Resilience defaults:** timeout + retry with exponential backoff for transient failures.
8. **Error behavior:** stderr error messages + non-zero exit code for hard failures.
9. **Testing strategy:** fixture parser tests + command contract tests for markdown/json output.
10. **Release target:** macOS-first binary distribution for v1.

## Deferred by Default

- Built-in MCP server
- Offline full crawler/index pipeline
- Multi-platform binary distribution (Linux/Windows)
