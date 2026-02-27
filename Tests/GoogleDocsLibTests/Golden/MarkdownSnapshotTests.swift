import Testing
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
}
