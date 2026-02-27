import Testing
import Foundation
@testable import GoogleDocsLib

struct MarkdownSnapshotTests {
    @Test
    func searchMarkdownSnapshot() {
        let output = MarkdownRenderer.renderSearchResults(
            "compose",
            [
                SearchResult(
                    title: "Compose docs",
                    url: "https://developer.android.com/develop/ui/compose",
                    snippet: "Declarative UI toolkit",
                    source: "android",
                    score: 1.0
                )
            ]
        )

        let expected = """
        # Search Results for \"compose\"

        ## 1. Compose docs
        - URL: https://developer.android.com/develop/ui/compose
        - Source: android
        - Snippet: Declarative UI toolkit

        """

        #expect(output == expected)
    }

    @Test
    func readmeUsageSectionsSnapshot() throws {
        let readme = try String(contentsOf: readmeURL(), encoding: .utf8)

        #expect(readme.contains("## Human CLI Usage"))
        #expect(readme.contains("## AI-Agent Usage"))
        #expect(readme.contains("swift build -c release"))
        #expect(readme.contains("ads search \"viewmodel\" --limit 5"))
        #expect(readme.contains("ads doc \"topic/libraries/architecture/viewmodel\" --json"))
    }

    private func readmeURL() -> URL {
        let fileURL = URL(fileURLWithPath: #filePath)
        return fileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("README.md")
    }
}
