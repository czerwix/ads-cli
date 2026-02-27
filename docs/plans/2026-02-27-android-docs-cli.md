# Android Docs CLI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Swift CLI (macOS-first) that mirrors `sad-cli` behavior for Android/Kotlin/Jetpack documentation search and retrieval.

**Architecture:** Keep executable thin and move all logic into a library module. Use provider adapters per source (Android/Kotlin/Jetpack) behind shared protocols, then normalize into one output contract rendered as Markdown or JSON.

**Tech Stack:** Swift 6, Swift Argument Parser, URLSession, Swift Testing/XCTest, fixture-based HTTP mocks.

---

### Task 1: Bootstrap package and command entrypoint

**Files:**
- Create: `Package.swift`
- Create: `Sources/ads/main.swift`
- Create: `Sources/GoogleDocsLib/CLI/RootCommand.swift`
- Test: `Tests/GoogleDocsLibTests/Smoke/RootCommandSmokeTests.swift`

### Task 2: Define core models and output contract

**Files:**
- Create: `Sources/GoogleDocsLib/Models/SearchResult.swift`
- Create: `Sources/GoogleDocsLib/Models/DocumentPage.swift`
- Create: `Sources/GoogleDocsLib/Models/RelatedTopic.swift`
- Create: `Sources/GoogleDocsLib/Output/RenderFormat.swift`
- Create: `Sources/GoogleDocsLib/Output/MarkdownRenderer.swift`
- Create: `Sources/GoogleDocsLib/Output/JSONRenderer.swift`
- Test: `Tests/GoogleDocsLibTests/Output/RendererContractTests.swift`

### Task 3: HTTP client with retry/timeouts and error mapping

**Files:**
- Create: `Sources/GoogleDocsLib/Networking/HTTPClient.swift`
- Create: `Sources/GoogleDocsLib/Networking/RetryPolicy.swift`
- Create: `Sources/GoogleDocsLib/Errors/CLIError.swift`
- Test: `Tests/GoogleDocsLibTests/Networking/HTTPClientTests.swift`

### Task 4: Implement `search` across Android/Kotlin/Jetpack providers

**Files:**
- Create: `Sources/GoogleDocsLib/Providers/DocsProvider.swift`
- Create: `Sources/GoogleDocsLib/Providers/AndroidDocsProvider.swift`
- Create: `Sources/GoogleDocsLib/Providers/KotlinDocsProvider.swift`
- Create: `Sources/GoogleDocsLib/Providers/JetpackDocsProvider.swift`
- Create: `Sources/GoogleDocsLib/Commands/SearchCommand.swift`
- Test: `Tests/GoogleDocsLibTests/Commands/SearchCommandTests.swift`
- Test: `Tests/GoogleDocsLibTests/Providers/SearchProviderParsingTests.swift`

### Task 5: Implement `doc` command resolution and extraction

**Files:**
- Create: `Sources/GoogleDocsLib/Commands/DocCommand.swift`
- Create: `Sources/GoogleDocsLib/Parsing/DocumentExtractor.swift`
- Modify: `Sources/GoogleDocsLib/Providers/*` (resolve-by-path support)
- Test: `Tests/GoogleDocsLibTests/Commands/DocCommandTests.swift`
- Test: `Tests/GoogleDocsLibTests/Parsing/DocumentExtractorTests.swift`

### Task 6: Implement `related` and `platform`

**Files:**
- Create: `Sources/GoogleDocsLib/Commands/RelatedCommand.swift`
- Create: `Sources/GoogleDocsLib/Commands/PlatformCommand.swift`
- Create: `Sources/GoogleDocsLib/Parsing/RelatedExtractor.swift`
- Create: `Sources/GoogleDocsLib/Parsing/PlatformExtractor.swift`
- Test: `Tests/GoogleDocsLibTests/Commands/RelatedCommandTests.swift`
- Test: `Tests/GoogleDocsLibTests/Commands/PlatformCommandTests.swift`

### Task 7: Implement `frameworks` listing command

**Files:**
- Create: `Sources/GoogleDocsLib/Commands/FrameworksCommand.swift`
- Create: `Sources/GoogleDocsLib/Data/FrameworkCatalog.swift`
- Test: `Tests/GoogleDocsLibTests/Commands/FrameworksCommandTests.swift`

### Task 8: Finish quality gates and release packaging

**Files:**
- Create: `README.md`
- Create: `.github/workflows/ci.yml`
- Create: `docs/contracts/json-schema.md`
- Create: `scripts/release/check.sh`
- Test: `Tests/GoogleDocsLibTests/Golden/MarkdownSnapshotTests.swift`
