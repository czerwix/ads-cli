# Search Relevance Quality Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove noisy search entries such as "Skip to main content", improve top-result relevance, and keep all existing `ads` command contracts stable.

**Architecture:** Keep the provider -> parser -> runner flow, but make relevance explicit. Add source-level relevance metadata, suppress noise links at parse time, and apply stable ranking in `SearchCommandRunner` before final limit truncation. Validate with RED/GREEN tests first, then full-suite and CLI smoke verification.

**Tech Stack:** Swift 6, Swift Testing, fixture-backed parser tests, command-level runner tests.

---

### Task 1: Initialize orchestration artifacts and status tracking

**Files:**
- Update (local log): `DECISIONS.md`
- Update (local log): `PROGRESS.md`
- Create: `docs/plans/2026-02-27-search-relevance-quality-implementation.md`

**Step 1: Record execution model decision**
Document hybrid mode: `executing-plans` for batch control + `subagent-driven-development` for per-task implementation/review loops.

**Step 2: Initialize progress state**
Add task entries for Tasks 1-9 with owner/result placeholders.

### Task 2: Add parser-level RED tests for relevance noise suppression

**Files:**
- Create: `Tests/GoogleDocsLibTests/Fixtures/Search/android-search-results-with-nav-noise.html`
- Create: `Tests/GoogleDocsLibTests/Fixtures/Search/kotlin-search-results-mixed-relevance.html`
- Modify: `Tests/GoogleDocsLibTests/Providers/SearchProviderParsingTests.swift`

**Step 1: Write failing tests**
Add RED tests for:
- nav/chrome title suppression
- fragment/query-only chrome link suppression
- preserving valid docs links in mixed HTML

**Step 2: Run RED verification**
Run: `swift test --filter SearchProviderParsingTests`
Expected: new relevance tests fail.

### Task 3: Add command-level RED tests for ranking quality

**Files:**
- Modify: `Tests/GoogleDocsLibTests/Commands/SearchCommandTests.swift`

**Step 1: Write failing tests**
Add RED tests for:
- title query match ranking preference
- URL query match ranking preference
- ranking applied before final limit
- noisy nav entries not appearing in top results

**Step 2: Run RED verification**
Run: `swift test --filter SearchCommandTests`
Expected: new ranking tests fail.

### Task 4: Add source-level relevance metadata model

**Files:**
- Modify: `Sources/GoogleDocsLib/Providers/SourceDefinition.swift`
- Modify: `Sources/GoogleDocsLib/Providers/SourceRegistry.swift`
- Modify: `Tests/GoogleDocsLibTests/Providers/SourceRegistryTests.swift`

**Step 1: Extend source model**
Add fields for relevance policy (preferred paths and blocked phrases/fragments).

**Step 2: Populate defaults per source**
Define safe prefix lists and common blocked navigation phrases.

**Step 3: Verify tests**
Run: `swift test --filter SourceRegistryTests`
Expected: pass.

### Task 5: Implement parser noise suppression and relevance scoring

**Files:**
- Modify: `Sources/GoogleDocsLib/Providers/SearchHTMLParser.swift`
- Modify: `Tests/GoogleDocsLibTests/Providers/SearchProviderParsingTests.swift` (if needed)

**Step 1: Suppress noisy links**
Reject entries by blocked title phrases, blocked fragments, and chrome href patterns.

**Step 2: Respect source preferred path prefixes**
Retain entries aligned with source doc paths and de-prioritize non-matching entries.

**Step 3: Introduce deterministic score heuristic**
Use query/title/url matching to compute score for ranking.

**Step 4: Verify parser tests**
Run: `swift test --filter SearchProviderParsingTests`
Expected: pass.

### Task 6: Apply stable relevance ordering in search runner

**Files:**
- Modify: `Sources/GoogleDocsLib/Commands/SearchCommand.swift`
- Modify: `Tests/GoogleDocsLibTests/Commands/SearchCommandTests.swift`

**Step 1: Rank before limit**
After merge + filters, order by score descending with stable tie-breaker by original order.

**Step 2: Verify runner tests**
Run: `swift test --filter SearchCommandTests`
Expected: pass.

### Task 7: Full-suite verification

**Files:**
- Modify only if regressions appear.

**Step 1: Run full suite**
Run: `swift test`
Expected: all tests pass.

**Step 2: Fix regressions if needed**
Iterate via subagent implementer + spec + quality reviews.

### Task 8: Runtime smoke verification for all commands

**Files:**
- Update (local log): `PROGRESS.md`
- Update (local log): `DECISIONS.md` (if autonomous choices made)

**Step 1: Run local binary matrix**

```bash
swift run ads --version
swift run ads --help
swift run ads sources --json
swift run ads search "viewmodel" --limit 5 --json
swift run ads search "compose state" --official-only --limit 5 --json
swift run ads search "compose state" --no-official-only --limit 5 --json
swift run ads search "navigation" --source android --kind guide --limit 5 --json
swift run ads doc "topic/libraries/architecture/viewmodel" --json
swift run ads related "topic/libraries/architecture/viewmodel" --json
swift run ads platform "topic/libraries/architecture/viewmodel" --json
swift run ads frameworks --json
```

**Step 2: Validate relevance improvements**
Top search results should exclude obvious nav/chrome entries.

### Task 9: Final subagent review and completion summary

**Files:**
- Update (local log): `PROGRESS.md`
- Update (local log): `DECISIONS.md`

**Step 1: Final review subagent**
Obtain APPROVED/CHANGES_REQUIRED verdict.

**Step 2: Publish compact summary**
Include links to:
- `docs/plans/2026-02-27-search-relevance-quality-implementation.md`
- `DECISIONS.md`
- `PROGRESS.md`

## Execution pattern

- Use as many subagents as possible.
- Orchestrator does not implement feature code directly.
- For each implementation task: implementer -> spec reviewer -> code-quality reviewer.
- Run verification commands after each stage.
