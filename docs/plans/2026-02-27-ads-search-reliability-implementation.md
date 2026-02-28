# ADS Search Reliability Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix `ads search` returning empty arrays for common live queries while preserving existing CLI contracts and filters.

**Architecture:** Keep command/filter logic in `SearchCommandRunner` intact and harden HTML parsing plus regression tests. Use fixture-based tests for deterministic failures and verify end-to-end behavior with CLI smoke checks.

**Tech Stack:** Swift 6, Swift Testing, Swift Argument Parser, fixture-based parser tests.

---

### Task 1: Create execution tracking artifacts

**Files:**
- Create: `DECISIONS.md`
- Create: `PROGRESS.md`

**Step 1: Create `DECISIONS.md` with initial decisions**

```md
# DECISIONS

## D-001
- Date: 2026-02-27
- Context: User requested both executing-plans and subagent-driven-development with maximal subagent usage.
- Decision: Use executing-plans for batch governance and subagent-driven-development for per-task implementation/review loops.
- Rationale: Maximizes subagent orchestration while preserving checkpoints.
- Impact: More agent invocations, stronger quality gates.
```

**Step 2: Create `PROGRESS.md` task log**

```md
# PROGRESS

## Status
- Plan: docs/plans/2026-02-27-ads-search-reliability-implementation.md
- Current Phase: In progress
- Current Task: Task 1

## Task Log
- Task 1: pending
- Task 2: pending
- Task 3: pending
- Task 4: pending
- Task 5: pending
- Task 6: pending
- Task 7: pending
```

**Step 3: Commit**

```bash
git add DECISIONS.md PROGRESS.md docs/plans/2026-02-27-ads-search-reliability-implementation.md
git commit -m "docs: add search reliability execution plan and trackers"
```

### Task 2: Add failing parser regression fixtures and tests (RED)

**Files:**
- Modify: `Tests/GoogleDocsLibTests/Providers/SearchProviderParsingTests.swift`
- Create: `Tests/GoogleDocsLibTests/Fixtures/Search/android-search-results-complex.html`
- Create: `Tests/GoogleDocsLibTests/Fixtures/Search/kotlin-search-results-complex.html`

**Step 1: Add fixture-backed tests for realistic HTML**

Include failing tests for:
- multiline/nested anchor content
- single-quoted attributes
- noisy wrapper markup around links

**Step 2: Verify failing state**

Run: `swift test --filter SearchProviderParsingTests`
Expected: New tests fail before parser implementation.

**Step 3: Commit failing tests**

```bash
git add Tests/GoogleDocsLibTests/Providers/SearchProviderParsingTests.swift Tests/GoogleDocsLibTests/Fixtures/Search
git commit -m "test(search): add complex HTML parser regression fixtures"
```

### Task 3: Add command-level regressions for empty-search scenarios (RED)

**Files:**
- Modify: `Tests/GoogleDocsLibTests/Commands/SearchCommandTests.swift`

**Step 1: Add failing command tests**

Cover:
- non-empty merged results from providers remain non-empty after filters when expected
- official-only and no-official-only behavior unchanged
- source/kind filtering still deterministic

**Step 2: Verify failing state**

Run: `swift test --filter SearchCommandTests`
Expected: New regression tests fail before implementation.

**Step 3: Commit failing tests**

```bash
git add Tests/GoogleDocsLibTests/Commands/SearchCommandTests.swift
git commit -m "test(search): add command-level empty-result regressions"
```

### Task 4: Harden search HTML parser implementation (GREEN)

**Files:**
- Modify: `Sources/GoogleDocsLib/Providers/SearchHTMLParser.swift`

**Step 1: Implement robust anchor extraction**

Requirements:
- parse both single and double quoted `href`
- support multiline and nested HTML inside anchor text
- keep URL resolution and metadata assignment behavior

**Step 2: Verify parser tests pass**

Run: `swift test --filter SearchProviderParsingTests`
Expected: PASS.

**Step 3: Verify command tests pass**

Run: `swift test --filter SearchCommandTests`
Expected: PASS.

**Step 4: Commit implementation**

```bash
git add Sources/GoogleDocsLib/Providers/SearchHTMLParser.swift
git commit -m "fix(search): parse real-world docs markup reliably"
```

### Task 5: Expand edge-case coverage and refactor (REFACTOR)

**Files:**
- Modify: `Tests/GoogleDocsLibTests/Providers/SearchProviderParsingTests.swift`
- Modify: `Sources/GoogleDocsLib/Providers/SearchHTMLParser.swift` (if needed)

**Step 1: Add edge tests**

Cover:
- empty anchor text
- malformed href ignored
- relative/absolute URL mix in same HTML

**Step 2: Refactor only if needed**

Keep behavior unchanged while simplifying parsing internals.

**Step 3: Verify focused tests**

Run:
- `swift test --filter SearchProviderParsingTests`
- `swift test --filter SearchCommandTests`

Expected: PASS.

**Step 4: Commit refactor/coverage**

```bash
git add Tests/GoogleDocsLibTests/Providers/SearchProviderParsingTests.swift Sources/GoogleDocsLib/Providers/SearchHTMLParser.swift
git commit -m "test(search): add edge-case parser coverage"
```

### Task 6: Full test verification

**Files:**
- Modify only if regressions discovered.

**Step 1: Run full suite**

Run: `swift test`
Expected: PASS.

**Step 2: If failures, fix and re-run**

Fix via implementer subagent, then re-run `swift test` until clean.

### Task 7: CLI smoke verification

**Files:**
- Update: `PROGRESS.md`
- Update: `DECISIONS.md` (if autonomous decisions were needed)

**Step 1: Run smoke matrix**

```bash
ads --version
ads --help
ads sources --json
ads search "viewmodel" --limit 3 --json
ads search "compose state" --official-only --limit 3 --json
ads search "compose state" --no-official-only --limit 3 --json
ads doc "topic/libraries/architecture/viewmodel" --json
ads related "topic/libraries/architecture/viewmodel" --json
ads platform "topic/libraries/architecture/viewmodel" --json
ads frameworks --json
ads frameworks --filter compose --json
```

**Step 2: Log outcomes**

Record pass/fail and key evidence in `PROGRESS.md`.

**Step 3: Final integration commit**

```bash
git add PROGRESS.md DECISIONS.md
git commit -m "docs: record execution decisions and verification progress"
```
