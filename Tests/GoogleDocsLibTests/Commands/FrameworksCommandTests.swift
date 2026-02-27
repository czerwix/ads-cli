import Testing
@testable import GoogleDocsLib

struct FrameworksCommandTests {
    @Test
    func frameworksRunnerFiltersBySubstring() throws {
        let output = try FrameworksCommandRunner.run(filter: "compose", format: .markdown)

        #expect(output.contains("compose".capitalized))
    }

    @Test
    func frameworksRunnerCanReturnJSON() throws {
        let output = try FrameworksCommandRunner.run(filter: "", format: .json)

        #expect(output.contains("\"name\""))
        #expect(output.contains("Android Framework"))
    }
}
