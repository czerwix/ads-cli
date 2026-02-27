import Testing
@testable import GoogleDocsLib

struct RelatedCommandTests {
    @Test
    func relatedRunnerOutputsRelatedTopics() async throws {
        let output = try await RelatedCommandRunner.run(
            pathOrURL: "viewmodel",
            format: .markdown,
            provider: StubRelatedProvider(),
            client: HTTPClient()
        )

        #expect(output.contains("LiveData"))
        #expect(output.contains("SavedStateHandle"))
    }
}

private struct StubRelatedProvider: DocsProvider {
    let source = "android"

    func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        []
    }

    func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        DocumentPage(
            title: "ViewModel",
            url: "https://developer.android.com/topic/libraries/architecture/viewmodel",
            summary: "",
            sections: [],
            codeBlocks: [],
            relatedLinks: [
                RelatedTopic(title: "LiveData", url: "https://developer.android.com/topic/libraries/architecture/livedata"),
                RelatedTopic(title: "SavedStateHandle", url: "https://developer.android.com/topic/libraries/architecture/viewmodel-savedstate")
            ],
            metadata: [:]
        )
    }
}
