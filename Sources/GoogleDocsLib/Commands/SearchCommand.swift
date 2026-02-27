import ArgumentParser
import Foundation

public struct SearchCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search Android, Kotlin, Jetpack, Firebase, Play Services, and Material docs."
    )

    @Argument(help: "Query text")
    var query: String

    @Option(name: .long, help: "Maximum number of results.")
    var limit: Int = 10

    @Option(name: .long, help: "Filter results by source identifier.")
    var source: String?

    @Option(name: .long, help: "Filter results by content kind.")
    var kind: ContentKind?

    @Flag(name: .long, inversion: .prefixedNo, help: "Only include official results.")
    var officialOnly = true

    @Flag(name: .long, help: "Render output as JSON.")
    var json = false

    public init() {}

    public mutating func run() async throws {
        let format: RenderFormat = json ? .json : .markdown
        let output = try await SearchCommandRunner.run(
            query: query,
            limit: limit,
            format: format,
            source: source,
            kind: kind,
            officialOnly: officialOnly,
            providers: DefaultProviders.all,
            client: HTTPClient()
        )

        print(output)
    }
}

public enum SearchCommandRunner {
    public static func run(
        query: String,
        limit: Int,
        format: RenderFormat,
        source: String?,
        kind: ContentKind?,
        officialOnly: Bool = true,
        providers: [any DocsProvider],
        client: HTTPClient
    ) async throws -> String {
        var resultsByProvider: [[SearchResult]] = []
        var failedProviders = 0

        for provider in providers {
            do {
                let results = try await provider.search(query: query, limit: limit, client: client)
                resultsByProvider.append(results)
            } catch {
                failedProviders += 1
            }
        }

        if failedProviders == providers.count {
            throw CLIError.network("Search failed for all providers.")
        }

        let merged = mergeResults(resultsByProvider, limit: limit)
        let filtered = applyFilters(
            merged,
            source: normalizedSource(source),
            kind: kind,
            officialOnly: officialOnly,
            limit: limit
        )
        switch format {
        case .markdown:
            return MarkdownRenderer.renderSearchResults(query, filtered)
        case .json:
            return try JSONRenderer.renderSearchResults(filtered)
        }
    }

    private static func mergeResults(_ resultsByProvider: [[SearchResult]], limit: Int) -> [SearchResult] {
        guard limit > 0 else {
            return []
        }

        var merged: [SearchResult] = []
        var depth = 0

        while merged.count < limit {
            var appended = false

            for providerResults in resultsByProvider {
                guard depth < providerResults.count else {
                    continue
                }

                merged.append(providerResults[depth])
                appended = true

                if merged.count == limit {
                    break
                }
            }

            if !appended {
                break
            }

            depth += 1
        }

        return merged
    }

    private static func applyFilters(
        _ results: [SearchResult],
        source: String?,
        kind: ContentKind?,
        officialOnly: Bool,
        limit: Int
    ) -> [SearchResult] {
        guard limit > 0 else {
            return []
        }

        let filtered = results.filter { result in
            if officialOnly && !result.official {
                return false
            }

            if let source, !matchesSource(result, source: source) {
                return false
            }

            if let kind, result.kind != kind {
                return false
            }

            return true
        }

        return Array(filtered.prefix(limit))
    }

    private static func matchesSource(_ result: SearchResult, source: String) -> Bool {
        let sourceId = result.sourceId.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if sourceId == source {
            return true
        }

        return result.source.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == source
    }

    private static func normalizedSource(_ source: String?) -> String? {
        guard let source else {
            return nil
        }

        let normalized = source.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized.isEmpty ? nil : normalized
    }
}

enum DefaultProviders {
    static let all: [any DocsProvider] = [
        AndroidDocsProvider(),
        KotlinDocsProvider(),
        JetpackDocsProvider(),
        GooglePlayServicesProvider(),
        FirebaseDocsProvider(),
        MaterialDesignProvider()
    ]
}

extension ContentKind: ExpressibleByArgument {}
