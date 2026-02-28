import Testing
@testable import GoogleDocsLib

struct RootCommandSmokeTests {
    @Test
    func rootCommandVersionMatchesCurrentRelease() {
        #expect(RootCommand.configuration.version == "0.1.4")
    }

    @Test
    func helpReflectsAdsNamingAndIncludesSearchSubcommand() throws {
        let help = RootCommand.helpMessage()

        #expect(help.contains("USAGE: ads"))
        #expect(help.contains("search"))
        #expect(help.contains("sources"))
    }
}
