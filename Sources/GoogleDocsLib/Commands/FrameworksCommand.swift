import ArgumentParser
import Foundation

public struct FrameworksCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "frameworks",
        abstract: "List supported Android and Kotlin framework categories."
    )

    @Option(name: .long, help: "Filter frameworks by text.")
    var filter: String = ""

    @Flag(name: .long, help: "Render output as JSON.")
    var json = false

    public init() {}

    public func run() throws {
        let format: RenderFormat = json ? .json : .markdown
        print(try FrameworksCommandRunner.run(filter: filter, format: format))
    }
}

public enum FrameworksCommandRunner {
    public static func run(filter: String, format: RenderFormat) throws -> String {
        let normalized = filter.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let entries = FrameworkCatalog.all.filter { item in
            normalized.isEmpty || item.name.lowercased().contains(normalized) || item.slug.lowercased().contains(normalized)
        }

        switch format {
        case .markdown:
            var lines = ["# Frameworks", ""]
            for entry in entries {
                lines.append("- \(entry.name) (`\(entry.slug)`): \(entry.description)")
            }
            return lines.joined(separator: "\n")
        case .json:
            return try JSONRenderer.renderFrameworks(entries)
        }
    }
}
