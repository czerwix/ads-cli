import ArgumentParser

@available(macOS 13.0, *)
public struct RootCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "ads",
        abstract: "Search Android, Kotlin, Jetpack, Firebase, Play Services, and Material docs.",
        version: "0.1.5",
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
