import Testing
import Foundation
@testable import GoogleDocsLib

struct SearchCommandTests {
    @Test
    func searchRunnerRendersMarkdown() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(
                    title: "Compose basics",
                    url: "https://developer.android.com/develop/ui/compose",
                    snippet: "Build UIs with Compose",
                    source: "android",
                    score: 1.0,
                    official: true
                )
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "compose",
            limit: 5,
            format: .markdown,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        #expect(output.contains("Compose basics"))
        #expect(output.contains("https://developer.android.com/develop/ui/compose"))
    }

    @Test
    func searchRunnerRendersJSON() async throws {
        let provider = StubProvider(
            source: "kotlin",
            results: [
                SearchResult(
                    title: "Kotlin docs",
                    url: "https://kotlinlang.org/docs/home.html",
                    snippet: "Home",
                    source: "kotlin",
                    score: 1.0,
                    official: true
                )
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "kotlin",
            limit: 5,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        #expect(output.contains("\"title\""))
        #expect(output.contains("Kotlin docs"))
    }

    @Test
    func searchRunnerMergesAcrossProvidersBeforeApplyingLimit() async throws {
        let android = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "A1", url: "https://a/1", snippet: "", source: "android", score: 1.0, official: true),
                SearchResult(title: "A2", url: "https://a/2", snippet: "", source: "android", score: 1.0, official: true)
            ]
        )
        let kotlin = StubProvider(
            source: "kotlin",
            results: [
                SearchResult(title: "K1", url: "https://k/1", snippet: "", source: "kotlin", score: 1.0, official: true),
                SearchResult(title: "K2", url: "https://k/2", snippet: "", source: "kotlin", score: 1.0, official: true)
            ]
        )
        let jetpack = StubProvider(
            source: "jetpack",
            results: [
                SearchResult(title: "J1", url: "https://j/1", snippet: "", source: "jetpack", score: 1.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "merge",
            limit: 4,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [android, kotlin, jetpack],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["A1", "K1", "J1", "A2"])
    }

    @Test
    func searchRunnerRanksTitleQueryMatchAheadOfNonMatchingResult() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "Android docs home", url: "https://developer.android.com/docs", snippet: "", source: "android", score: 9.0, official: true),
                SearchResult(title: "ViewModel overview", url: "https://developer.android.com/topic/libraries/architecture/viewmodel", snippet: "", source: "android", score: 1.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "viewmodel",
            limit: 2,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        let relevantIndex = decoded.firstIndex(where: { $0.title == "ViewModel overview" })
        let nonMatchingIndex = decoded.firstIndex(where: { $0.title == "Android docs home" })

        #expect(relevantIndex != nil)
        #expect(nonMatchingIndex != nil)
        if let relevantIndex, let nonMatchingIndex {
            #expect(relevantIndex < nonMatchingIndex)
        }
    }

    @Test
    func searchRunnerRanksURLQueryMatchAheadOfNonMatchingResult() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "Android docs home", url: "https://developer.android.com/docs", snippet: "", source: "android", score: 9.0, official: true),
                SearchResult(title: "Compose runtime guide", url: "https://developer.android.com/develop/ui/compose/state", snippet: "", source: "android", score: 1.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "state",
            limit: 2,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        let relevantIndex = decoded.firstIndex(where: { $0.title == "Compose runtime guide" })
        let nonMatchingIndex = decoded.firstIndex(where: { $0.title == "Android docs home" })

        #expect(relevantIndex != nil)
        #expect(nonMatchingIndex != nil)
        if let relevantIndex, let nonMatchingIndex {
            #expect(relevantIndex < nonMatchingIndex)
        }
    }

    @Test
    func searchRunnerAppliesRelevanceRankingBeforeFinalLimit() async throws {
        let weaker = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "Android docs home", url: "https://developer.android.com/docs", snippet: "", source: "android", score: 1.0, official: true)
            ]
        )
        let stronger = StubProvider(
            source: "kotlin",
            results: [
                SearchResult(title: "Compose state", url: "https://kotlinlang.org/docs/compose-state", snippet: "", source: "kotlin", score: 5.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "state",
            limit: 1,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [weaker, stronger],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.first?.title == "Compose state")
    }

    @Test
    func searchRunnerDeduplicatesCanonicalURLsBeforeFinalLimit() async throws {
        let android = StubProvider(
            source: "android",
            results: [
                SearchResult(
                    title: "Navigation guide",
                    url: "https://developer.android.com/guide/navigation",
                    snippet: "",
                    source: "android",
                    score: 5.0,
                    official: true
                ),
                SearchResult(
                    title: "Navigation guide (fragment)",
                    url: "https://developer.android.com/guide/navigation#top",
                    snippet: "",
                    source: "android",
                    score: 4.0,
                    official: true
                )
            ]
        )
        let kotlin = StubProvider(
            source: "kotlin",
            results: [
                SearchResult(
                    title: "Navigation tutorial",
                    url: "https://kotlinlang.org/docs/navigation-tutorial.html",
                    snippet: "",
                    source: "kotlin",
                    score: 3.0,
                    official: true
                )
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "navigation",
            limit: 2,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [android, kotlin],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["Navigation guide", "Navigation tutorial"])
    }

    @Test
    func searchRunnerUsesStableOrderWhenRelevanceAndScoreTie() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "State in Compose", url: "https://developer.android.com/topic/compose/state-1", snippet: "", source: "android", score: 3.0, official: true),
                SearchResult(title: "State for ViewModel", url: "https://developer.android.com/topic/compose/state-2", snippet: "", source: "android", score: 3.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "state",
            limit: 2,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["State in Compose", "State for ViewModel"])
    }

    @Test
    func searchRunnerIgnoresShortQueryTokensForRankingConsistency() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "UI widgets", url: "https://developer.android.com/ui/widgets", snippet: "", source: "android", score: 1.0, official: true),
                SearchResult(title: "Architecture overview", url: "https://developer.android.com/topic/libraries/architecture", snippet: "", source: "android", score: 9.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "ui",
            limit: 2,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["Architecture overview", "UI widgets"])
    }

    @Test
    func searchRunnerDoesNotSurfaceNavChromeStyleEntriesAtTop() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "Skip to main content", url: "https://developer.android.com/#main-content", snippet: "", source: "android", score: 0.2, official: true),
                SearchResult(title: "Android Developers", url: "https://developer.android.com", snippet: "", source: "android", score: 0.1, official: true),
                SearchResult(title: "ViewModel overview", url: "https://developer.android.com/topic/libraries/architecture/viewmodel", snippet: "", source: "android", score: 5.0, official: true),
                SearchResult(title: "Saved state guide", url: "https://developer.android.com/topic/libraries/architecture/saved-state", snippet: "", source: "android", score: 4.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "viewmodel",
            limit: 4,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        let topResults = Array(decoded.prefix(2))
        let topTitles = topResults.map(\.title)

        #expect(decoded.first?.title == "ViewModel overview")
        #expect(!topTitles.contains("Skip to main content"))
        #expect(!topTitles.contains("Android Developers"))
    }

    @Test
    func searchRunnerFallsBackToCanonicalViewModelResultsWhenFilteredResultsAreEmpty() async throws {
        let provider = StubProvider(
            source: "android",
            results: []
        )

        let output = try await SearchCommandRunner.run(
            query: "viewmodel",
            limit: 5,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        let urls = Set(decoded.map(\.url))

        #expect(urls.contains("https://developer.android.com/topic/libraries/architecture/viewmodel"))
        #expect(urls.contains("https://developer.android.com/reference/androidx/lifecycle/ViewModel"))
    }

    @Test
    func searchRunnerDoesNotApplyViewModelFallbackWhenProviderAlreadyHasMatchingResults() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(
                    title: "ViewModel from provider",
                    url: "https://developer.android.com/topic/libraries/architecture/viewmodel-custom",
                    snippet: "",
                    source: "android",
                    score: 4.0,
                    official: true
                )
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "viewmodel",
            limit: 5,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.count == 1)
        #expect(decoded.first?.title == "ViewModel from provider")
    }

    @Test
    func searchRunnerAppliesKindAndSourceFiltersToViewModelFallbackResults() async throws {
        let provider = StubProvider(source: "android", results: [])

        let referenceOnlyOutput = try await SearchCommandRunner.run(
            query: "viewmodel",
            limit: 5,
            format: .json,
            source: nil,
            kind: .reference,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let referenceOnly = try JSONDecoder().decode([SearchResult].self, from: Data(referenceOnlyOutput.utf8))
        #expect(referenceOnly.map(\.url) == ["https://developer.android.com/reference/androidx/lifecycle/ViewModel"])

        let kotlinOnlyOutput = try await SearchCommandRunner.run(
            query: "viewmodel",
            limit: 5,
            format: .json,
            source: "kotlin",
            kind: nil,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let kotlinOnly = try JSONDecoder().decode([SearchResult].self, from: Data(kotlinOnlyOutput.utf8))
        #expect(kotlinOnly.isEmpty)
    }

    @Test
    func searchRunnerContinuesWhenAProviderFails() async throws {
        let failing = ThrowingProvider(source: "android")
        let working = StubProvider(
            source: "kotlin",
            results: [
                SearchResult(title: "Kotlin docs", url: "https://kotlinlang.org/docs/home.html", snippet: "", source: "kotlin", score: 1.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "kotlin",
            limit: 5,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [failing, working],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["Kotlin docs"])
    }

    @Test
    func searchRunnerThrowsClearErrorWhenAllProvidersFail() async {
        let providerA = ThrowingProvider(source: "android")
        let providerB = ThrowingProvider(source: "kotlin")

        do {
            _ = try await SearchCommandRunner.run(
                query: "kotlin",
                limit: 5,
                format: .json,
                source: nil,
                kind: nil,
                officialOnly: true,
                providers: [providerA, providerB],
                client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
            )
            Issue.record("Expected all providers to fail")
        } catch let error as CLIError {
            guard case let .network(message) = error else {
                Issue.record("Expected network error")
                return
            }

            #expect(message == "Search failed for all providers.")
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test
    func searchRunnerFiltersBySourceIdentifier() async throws {
        let android = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "Android one", url: "https://a/1", snippet: "", source: "android", score: 1.0, sourceId: "android", official: true),
                SearchResult(title: "Android two", url: "https://a/2", snippet: "", source: "android", score: 1.0, sourceId: "android", official: true)
            ]
        )
        let kotlin = StubProvider(
            source: "kotlin",
            results: [
                SearchResult(title: "Kotlin one", url: "https://k/1", snippet: "", source: "kotlin", score: 1.0, sourceId: "kotlin", official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "docs",
            limit: 10,
            format: .json,
            source: "kotlin",
            kind: nil,
            officialOnly: true,
            providers: [android, kotlin],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.sourceId) == ["kotlin"])
    }

    @Test
    func searchRunnerAppliesSourceFilterBeforeFinalLimit() async throws {
        let android = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "A1", url: "https://a/1", snippet: "", source: "android", score: 1.0, sourceId: "android", official: true),
                SearchResult(title: "A2", url: "https://a/2", snippet: "", source: "android", score: 1.0, sourceId: "android", official: true),
                SearchResult(title: "A3", url: "https://a/3", snippet: "", source: "android", score: 1.0, sourceId: "android", official: true)
            ]
        )
        let kotlin = StubProvider(
            source: "kotlin",
            results: [
                SearchResult(title: "K1", url: "https://k/1", snippet: "", source: "kotlin", score: 1.0, sourceId: "kotlin", official: true),
                SearchResult(title: "K2", url: "https://k/2", snippet: "", source: "kotlin", score: 1.0, sourceId: "kotlin", official: true),
                SearchResult(title: "K3", url: "https://k/3", snippet: "", source: "kotlin", score: 1.0, sourceId: "kotlin", official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "docs",
            limit: 3,
            format: .json,
            source: "kotlin",
            kind: nil,
            officialOnly: true,
            providers: [android, kotlin],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["K1", "K2", "K3"])
    }

    @Test
    func searchRunnerFiltersByKind() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "Reference", url: "https://a/ref", snippet: "", source: "android", score: 1.0, kind: .reference, official: true),
                SearchResult(title: "Guide", url: "https://a/guide", snippet: "", source: "android", score: 1.0, kind: .guide, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "docs",
            limit: 10,
            format: .json,
            source: nil,
            kind: .guide,
            officialOnly: true,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["Guide"])
    }

    @Test
    func searchRunnerExcludesUnofficialResultsByDefault() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "Unofficial", url: "https://x/1", snippet: "", source: "android", score: 1.0, official: false),
                SearchResult(title: "Official", url: "https://x/2", snippet: "", source: "android", score: 1.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "docs",
            limit: 10,
            format: .json,
            source: nil,
            kind: nil,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["Official"])
    }

    @Test
    func searchRunnerCanIncludeUnofficialResultsWhenFlagDisabled() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "Unofficial", url: "https://x/1", snippet: "", source: "android", score: 1.0, official: false),
                SearchResult(title: "Official", url: "https://x/2", snippet: "", source: "android", score: 1.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "docs",
            limit: 10,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: false,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["Unofficial", "Official"])
    }

    @Test
    func searchRunnerAppliesOfficialFilterBeforeFinalLimit() async throws {
        let android = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "A-Unofficial", url: "https://a/0", snippet: "", source: "android", score: 1.0, official: false),
                SearchResult(title: "A-Official-1", url: "https://a/1", snippet: "", source: "android", score: 1.0, official: true),
                SearchResult(title: "A-Official-2", url: "https://a/2", snippet: "", source: "android", score: 1.0, official: true)
            ]
        )
        let kotlin = StubProvider(
            source: "kotlin",
            results: [
                SearchResult(title: "K-Unofficial", url: "https://k/0", snippet: "", source: "kotlin", score: 1.0, official: false),
                SearchResult(title: "K-Official-1", url: "https://k/1", snippet: "", source: "kotlin", score: 1.0, official: true),
                SearchResult(title: "K-Official-2", url: "https://k/2", snippet: "", source: "kotlin", score: 1.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "docs",
            limit: 3,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [android, kotlin],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["A-Official-1", "K-Official-1", "A-Official-2"])
    }

    @Test
    func searchRunnerSupportsLegacyRunCallWithoutSourceAndKind() async throws {
        let provider = StubProvider(
            source: "android",
            results: [
                SearchResult(title: "Compose", url: "https://a/compose", snippet: "", source: "android", score: 1.0, official: true)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "compose",
            limit: 1,
            format: .json,
            providers: [provider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["Compose"])
    }

    @Test
    func searchRunnerKeepsMergedComplexFixtureResultsNonEmptyAfterOfficialFilter() async throws {
        let android = FixtureBackedAndroidProvider(html: try fixture(named: "android-search-results-complex"))
        let kotlin = FixtureBackedKotlinProvider(html: try fixture(named: "kotlin-search-results-complex"))

        let output = try await SearchCommandRunner.run(
            query: "overview",
            limit: 10,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [android, kotlin],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.count == 2)
        #expect(decoded.contains(where: { normalizeWhitespace($0.title) == "ViewModel overview" }))
        #expect(decoded.contains(where: { normalizeWhitespace($0.title) == "Coroutines overview" }))
    }

    @Test
    func searchRunnerOfficialToggleStillIncludesFixtureResultsWhenExpected() async throws {
        let fixtureProvider = FixtureBackedAndroidProvider(html: try fixture(named: "android-search-results-complex"))
        let unofficialProvider = StubProvider(
            source: "community",
            results: [
                SearchResult(title: "Community mirror", url: "https://community.example.dev/viewmodel", snippet: "", source: "community", score: 1.0, sourceId: "community", official: false)
            ]
        )

        let officialOnlyOutput = try await SearchCommandRunner.run(
            query: "viewmodel",
            limit: 10,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: true,
            providers: [fixtureProvider, unofficialProvider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )
        let officialOnlyDecoded = try JSONDecoder().decode([SearchResult].self, from: Data(officialOnlyOutput.utf8))
        #expect(officialOnlyDecoded.count == 1)
        #expect(officialOnlyDecoded.contains(where: { normalizeWhitespace($0.title) == "ViewModel overview" }))

        let includeUnofficialOutput = try await SearchCommandRunner.run(
            query: "viewmodel",
            limit: 10,
            format: .json,
            source: nil,
            kind: nil,
            officialOnly: false,
            providers: [fixtureProvider, unofficialProvider],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )
        let includeUnofficialDecoded = try JSONDecoder().decode([SearchResult].self, from: Data(includeUnofficialOutput.utf8))
        #expect(includeUnofficialDecoded.count == 2)
        #expect(includeUnofficialDecoded.contains(where: { normalizeWhitespace($0.title) == "ViewModel overview" }))
        #expect(includeUnofficialDecoded.contains(where: { $0.title == "Community mirror" }))
    }

    @Test
    func searchRunnerAppliesSourceAndKindFiltersToComplexFixtureResultsDeterministically() async throws {
        let android = FixtureBackedAndroidProvider(html: try fixture(named: "android-search-results-complex"))
        let kotlin = FixtureBackedKotlinProvider(html: try fixture(named: "kotlin-search-results-complex"))

        let output = try await SearchCommandRunner.run(
            query: "overview",
            limit: 10,
            format: .json,
            source: "kotlin",
            kind: .reference,
            officialOnly: true,
            providers: [android, kotlin],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.count == 1)
        #expect(decoded.contains(where: {
            $0.sourceId == "kotlin"
                && $0.kind == .reference
                && normalizeWhitespace($0.title) == "Coroutines overview"
        }))
    }

    private func fixture(named name: String) throws -> String {
        let fixtureURL = try repoRootURL()
            .appendingPathComponent("Tests/GoogleDocsLibTests/Fixtures/Search/\(name).html")
        return try String(contentsOf: fixtureURL, encoding: .utf8)
    }

    private func repoRootURL() throws -> URL {
        let fileManager = FileManager.default
        var current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

        while true {
            let packageSwiftURL = current.appendingPathComponent("Package.swift")
            if fileManager.fileExists(atPath: packageSwiftURL.path) {
                return current
            }

            let parent = current.deletingLastPathComponent()
            if parent == current {
                break
            }
            current = parent
        }

        throw CocoaError(.fileNoSuchFile)
    }

    private func normalizeWhitespace(_ value: String?) -> String {
        guard let value else { return "" }
        return value.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct StubProvider: DocsProvider {
    let source: String
    let results: [SearchResult]

    func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        Array(results.prefix(limit))
    }

    func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        DocumentPage(
            title: "",
            url: "",
            summary: "",
            sections: [],
            codeBlocks: [],
            relatedLinks: [],
            metadata: [:]
        )
    }
}

private struct ThrowingProvider: DocsProvider {
    let source: String

    func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        throw CLIError.network("Provider unavailable")
    }

    func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        throw CLIError.network("Provider unavailable")
    }
}

private struct FixtureBackedAndroidProvider: DocsProvider {
    let source = "android"
    let html: String

    func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        AndroidDocsProvider.parseSearchHTML(html, query: query, limit: limit)
    }

    func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        throw CLIError.network("Not implemented")
    }
}

private struct FixtureBackedKotlinProvider: DocsProvider {
    let source = "kotlin"
    let html: String

    func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        KotlinDocsProvider.parseSearchHTML(html, query: query, limit: limit)
    }

    func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        throw CLIError.network("Not implemented")
    }
}
