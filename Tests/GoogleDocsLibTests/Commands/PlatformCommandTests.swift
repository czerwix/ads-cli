import Testing
@testable import GoogleDocsLib

struct PlatformCommandTests {
    @Test
    func platformRunnerExtractsMetadata() async throws {
        let output = try await PlatformCommandRunner.run(
            pathOrURL: "viewmodel",
            format: .json,
            provider: StubPlatformProvider(),
            client: HTTPClient()
        )

        #expect(output.contains("\"androidApiLevel\""))
        #expect(output.contains("\"21\""))
    }
}

private struct StubPlatformProvider: DocsProvider {
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
            relatedLinks: [],
            metadata: [
                "androidApiLevel": "21",
                "artifact": "androidx.lifecycle:lifecycle-viewmodel"
            ]
        )
    }
}
