import ArgumentParser

public struct DocCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "doc",
        abstract: "Fetch documentation page by path or URL."
    )

    @Argument(help: "Doc path or URL")
    var pathOrURL: String

    @Flag(name: .long, help: "Render output as JSON.")
    var json = false

    public init() {}

    public mutating func run() async throws {
        let format: RenderFormat = json ? .json : .markdown
        let output = try await DocCommandRunner.run(
            pathOrURL: pathOrURL,
            format: format,
            provider: AndroidDocsProvider(),
            client: HTTPClient()
        )
        print(output)
    }
}

public enum DocCommandRunner {
    public static func run(
        pathOrURL: String,
        format: RenderFormat,
        provider: any DocsProvider,
        client: HTTPClient
    ) async throws -> String {
        let page = try await provider.doc(pathOrURL: pathOrURL, client: client)
        switch format {
        case .markdown:
            return MarkdownRenderer.renderDocument(page)
        case .json:
            return try JSONRenderer.renderDocument(page)
        }
    }
}
