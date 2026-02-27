import Testing
@testable import GoogleDocsLib

struct RootCommandSmokeTests {
    @Test
    func helpReflectsAdsNamingAndIncludesSearchSubcommand() throws {
        let help = RootCommand.helpMessage()

        #expect(help.contains("USAGE: ads"))
        #expect(help.contains("search"))
    }
}
