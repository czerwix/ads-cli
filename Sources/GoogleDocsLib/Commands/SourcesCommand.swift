import ArgumentParser

public struct SourcesCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "sources",
        abstract: "List supported documentation sources."
    )

    @Flag(name: .long, help: "Render output as JSON.")
    var json = false

    public init() {}

    public func run() throws {
        let format: RenderFormat = json ? .json : .markdown
        print(try SourcesCommandRunner.run(format: format))
    }
}

public enum SourcesCommandRunner {
    public static func run(format: RenderFormat) throws -> String {
        switch format {
        case .markdown:
            var lines = ["# Sources", ""]
            for source in SourceRegistry.all {
                lines.append("- \(source.displayName) (`\(source.id)`) - kind: \(source.kind.rawValue), official: \(source.official)")
            }
            return lines.joined(separator: "\n")
        case .json:
            return try JSONRenderer.renderSources(SourceRegistry.all)
        }
    }
}
