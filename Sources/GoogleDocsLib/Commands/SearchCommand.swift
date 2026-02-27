import ArgumentParser

public struct SearchCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search Android and Kotlin documentation."
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
        var allResults: [SearchResult] = []

        for provider in providers {
            let results = try await provider.search(query: query, limit: limit, client: client)
            allResults.append(contentsOf: results)
        }

        let merged = Array(allResults.prefix(limit))
        switch format {
        case .markdown:
            return MarkdownRenderer.renderSearchResults(query, merged)
        case .json:
            return try JSONRenderer.renderSearchResults(merged)
        }
    }
}

enum DefaultProviders {
    static let all: [any DocsProvider] = [
        AndroidDocsProvider(),
        KotlinDocsProvider(),
        JetpackDocsProvider()
    ]
}
