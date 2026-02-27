import Testing
@testable import GoogleDocsLib

struct RootCommandSmokeTests {
    @Test
    func helpIncludesSearchSubcommand() throws {
        let help = RootCommand.helpMessage()

        #expect(help.contains("search"))
    }
}
