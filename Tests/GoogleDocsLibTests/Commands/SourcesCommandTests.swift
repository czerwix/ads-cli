import Foundation
import Testing
@testable import GoogleDocsLib

struct SourcesCommandTests {
    @Test
    func sourcesRunnerRendersMarkdownFromSourceRegistry() throws {
        let output = try SourcesCommandRunner.run(format: .markdown)

        #expect(output.contains("# Sources"))
        #expect(output.contains("android"))
        #expect(output.contains("Android Developers"))
    }

    @Test
    func sourcesRunnerRendersJSONFromSourceRegistry() throws {
        let output = try SourcesCommandRunner.run(format: .json)
        let decoded = try JSONDecoder().decode([SourceDefinition].self, from: Data(output.utf8))

        #expect(decoded == SourceRegistry.all)
    }
}
