import Testing
@testable import GoogleDocsLib

struct RootCommandSmokeTests {
    @Test
    func rootCommandVersionMatchesCurrentRelease() {
        #expect(RootCommand.configuration.version == "0.1.5")
    }

    @Test
    func rootCommandOverviewMentionsAllSupportedSources() {
        #expect(
            RootCommand.configuration.abstract
                == "Search Android, Kotlin, Jetpack, Firebase, Play Services, and Material docs."
        )
    }

    @Test
    func helpReflectsAdsNamingAndIncludesSearchSubcommand() throws {
        let help = RootCommand.helpMessage()

        #expect(help.contains("USAGE: ads"))
        #expect(help.contains("search"))
        #expect(help.contains("sources"))
    }
}
