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
