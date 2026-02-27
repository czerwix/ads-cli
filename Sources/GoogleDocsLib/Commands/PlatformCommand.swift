import ArgumentParser
import Foundation

public struct PlatformCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "platform",
        abstract: "Show platform metadata for a documentation page."
    )

    @Argument(help: "Doc path or URL")
    var pathOrURL: String

    @Flag(name: .long, help: "Render output as JSON.")
    var json = false

    public init() {}

    public mutating func run() async throws {
        let format: RenderFormat = json ? .json : .markdown
        let output = try await PlatformCommandRunner.run(
            pathOrURL: pathOrURL,
            format: format,
            provider: AndroidDocsProvider(),
            client: HTTPClient()
        )
        print(output)
    }
}

public enum PlatformCommandRunner {
    public static func run(
        pathOrURL: String,
        format: RenderFormat,
        provider: any DocsProvider,
        client: HTTPClient
    ) async throws -> String {
        let page = try await provider.doc(pathOrURL: pathOrURL, client: client)

        switch format {
        case .markdown:
            var lines = ["# Platform Metadata for \(page.title)", ""]
            if page.metadata.isEmpty {
                lines.append("No platform metadata found.")
            } else {
                for key in page.metadata.keys.sorted() {
                    lines.append("- \(key): \(page.metadata[key] ?? "unknown")")
                }
            }
            return lines.joined(separator: "\n")
        case .json:
            let data = try JSONSerialization.data(withJSONObject: page.metadata, options: [.prettyPrinted, .sortedKeys])
            return String(decoding: data, as: UTF8.self)
        }
    }
}
