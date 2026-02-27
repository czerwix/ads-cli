import ArgumentParser

@available(macOS 13.0, *)
public struct RootCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "ads",
        abstract: "Search Google Android, Kotlin, and Jetpack documentation.",
        version: "0.1.0",
        subcommands: [
            SearchCommand.self,
            SourcesCommand.self,
            DocCommand.self,
            RelatedCommand.self,
            PlatformCommand.self,
            FrameworksCommand.self
        ]
    )

    public init() {}
}
