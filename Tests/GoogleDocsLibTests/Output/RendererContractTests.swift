import Foundation
import Testing
@testable import GoogleDocsLib

struct RendererContractTests {
    @Test
    func markdownSearchIncludesTitleAndURL() {
        let result = SearchResult(
            title: "Android ViewModel",
            url: "https://developer.android.com/topic/libraries/architecture/viewmodel",
            snippet: "Stores UI-related data.",
            source: "android",
            score: 0.98
        )

        let output = MarkdownRenderer.renderSearchResults("viewmodel", [result])

        #expect(output.contains("# Search Results for \"viewmodel\""))
        #expect(output.contains("Android ViewModel"))
        #expect(output.contains("https://developer.android.com/topic/libraries/architecture/viewmodel"))
    }

    @Test
    func jsonDocumentOutputUsesStableKeys() throws {
        let page = DocumentPage(
            title: "ViewModel",
            url: "https://developer.android.com/topic/libraries/architecture/viewmodel",
            summary: "Manages UI state.",
            sections: [
                DocumentSection(title: "Key points", body: "Survives configuration changes.")
            ],
            codeBlocks: ["class MainViewModel : ViewModel()"],
            relatedLinks: [
                RelatedTopic(title: "LiveData", url: "https://developer.android.com/topic/libraries/architecture/livedata")
            ],
            metadata: ["source": "android"]
        )

        let json = try JSONRenderer.renderDocument(page)
        let decoded = try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any]

        #expect(decoded?["title"] as? String == "ViewModel")
        #expect(decoded?["url"] as? String == "https://developer.android.com/topic/libraries/architecture/viewmodel")
        #expect(decoded?["summary"] as? String == "Manages UI state.")
        #expect(decoded?["sections"] != nil)
        #expect(decoded?["metadata"] != nil)
    }
}
