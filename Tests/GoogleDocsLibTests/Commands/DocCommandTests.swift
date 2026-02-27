import Testing
@testable import GoogleDocsLib

struct DocCommandTests {
    @Test
    func docRunnerReturnsMarkdownByDefault() async throws {
        let output = try await DocCommandRunner.run(
            pathOrURL: "viewmodel",
            format: .markdown,
            provider: StubDocProvider(),
            client: HTTPClient()
        )

        #expect(output.contains("# ViewModel"))
        #expect(output.contains("Manages UI data"))
    }

    @Test
    func docRunnerReturnsJSON() async throws {
        let output = try await DocCommandRunner.run(
            pathOrURL: "viewmodel",
            format: .json,
            provider: StubDocProvider(),
            client: HTTPClient()
        )

        #expect(output.contains("\"title\""))
        #expect(output.contains("ViewModel"))
    }
}

private struct StubDocProvider: DocsProvider {
    let source = "android"

    func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        []
    }

    func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        DocumentPage(
            title: "ViewModel",
            url: "https://developer.android.com/topic/libraries/architecture/viewmodel",
            summary: "Manages UI data",
            sections: [],
            codeBlocks: [],
            relatedLinks: [],
            metadata: ["source": "android"]
        )
    }
}
