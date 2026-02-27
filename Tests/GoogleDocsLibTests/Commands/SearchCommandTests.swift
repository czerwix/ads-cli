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
                    score: 1.0
                )
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "compose",
            limit: 5,
            format: .markdown,
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
                    score: 1.0
                )
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "kotlin",
            limit: 5,
            format: .json,
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
                SearchResult(title: "A1", url: "https://a/1", snippet: "", source: "android", score: 1.0),
                SearchResult(title: "A2", url: "https://a/2", snippet: "", source: "android", score: 1.0)
            ]
        )
        let kotlin = StubProvider(
            source: "kotlin",
            results: [
                SearchResult(title: "K1", url: "https://k/1", snippet: "", source: "kotlin", score: 1.0),
                SearchResult(title: "K2", url: "https://k/2", snippet: "", source: "kotlin", score: 1.0)
            ]
        )
        let jetpack = StubProvider(
            source: "jetpack",
            results: [
                SearchResult(title: "J1", url: "https://j/1", snippet: "", source: "jetpack", score: 1.0)
            ]
        )

        let output = try await SearchCommandRunner.run(
            query: "merge",
            limit: 4,
            format: .json,
            providers: [android, kotlin, jetpack],
            client: HTTPClient(session: .shared, retryPolicy: .init(maxAttempts: 1, baseDelayNanoseconds: 1))
        )

        let decoded = try JSONDecoder().decode([SearchResult].self, from: Data(output.utf8))
        #expect(decoded.map(\.title) == ["A1", "K1", "J1", "A2"])
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
