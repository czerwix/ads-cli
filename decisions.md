# DECISIONS

## Purpose
Record key project decisions that were made as implementation defaults during planning and execution.

## Core Decisions

1. **CLI working name (v1):** `ads`.
2. **Project structure:** thin executable + library module split.
3. **Provider-adapter design:** one adapter per source.
4. **Normalized output contract:** one shared schema for all commands/sources.
5. **v1 command set:** `search`, `doc`, `frameworks`, `related`, `platform`.
6. **Stateless runtime policy:** no local database/configuration.
7. **Network resilience defaults:** timeout + retry with exponential backoff.
8. **Failure behavior:** structured stderr errors and non-zero exit codes.
9. **Testing strategy:** fixture-driven parser tests + command contract tests.
10. **Release strategy:** macOS-first for v1.

## Deferred by Default

- Built-in MCP server
- Offline full indexing/crawling pipeline
- Multi-platform release (Linux/Windows)

## 2026-02-27 Orchestration Decisions

- Chose hidden project-local worktree directory `.worktrees/` because no existing worktree directory and no `CLAUDE.md` preference were found.
- Enforced hard cutover to `ads` with no compatibility shim, since no release exists.
- Added new `SearchResult` taxonomy fields with backward-compatible decoding defaults to avoid breaking legacy JSON payload consumers.
