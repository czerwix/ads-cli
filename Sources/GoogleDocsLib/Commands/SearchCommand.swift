import ArgumentParser

public struct SearchCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search Android, Kotlin, Jetpack, Firebase, Play Services, and Material docs."
    )

    @Argument(help: "Query text")
    var query: String

    @Option(name: .long, help: "Maximum number of results.")
    var limit: Int = 10

    @Flag(name: .long, help: "Render output as JSON.")
    var json = false

    public init() {}

    public mutating func run() async throws {
        let format: RenderFormat = json ? .json : .markdown
        let output = try await SearchCommandRunner.run(
            query: query,
            limit: limit,
            format: format,
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
        switch format {
        case .markdown:
            return MarkdownRenderer.renderSearchResults(query, merged)
        case .json:
            return try JSONRenderer.renderSearchResults(merged)
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
