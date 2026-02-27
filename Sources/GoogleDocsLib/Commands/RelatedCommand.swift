import ArgumentParser

public struct RelatedCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "related",
        abstract: "Show related topics for a documentation page."
    )

    @Argument(help: "Doc path or URL")
    var pathOrURL: String

    @Flag(name: .long, help: "Render output as JSON.")
    var json = false

    public init() {}

    public mutating func run() async throws {
        let format: RenderFormat = json ? .json : .markdown
        let output = try await RelatedCommandRunner.run(
            pathOrURL: pathOrURL,
            format: format,
            provider: AndroidDocsProvider(),
            client: HTTPClient()
        )

        print(output)
    }
}

public enum RelatedCommandRunner {
    public static func run(
        pathOrURL: String,
        format: RenderFormat,
        provider: any DocsProvider,
        client: HTTPClient
    ) async throws -> String {
        let page = try await provider.doc(pathOrURL: pathOrURL, client: client)

        switch format {
        case .markdown:
            if page.relatedLinks.isEmpty {
                return "No related topics found."
            }

            var lines = ["# Related Topics for \(page.title)", ""]
            for topic in page.relatedLinks {
                lines.append("- \(topic.title): \(topic.url)")
            }
            return lines.joined(separator: "\n")
        case .json:
            return try JSONRenderer.renderSearchResults(
                page.relatedLinks.map {
                    SearchResult(title: $0.title, url: $0.url, snippet: "", source: "related", score: 1.0)
                }
            )
        }
    }
}
