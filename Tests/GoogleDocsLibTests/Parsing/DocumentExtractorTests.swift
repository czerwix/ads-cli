import Testing
@testable import GoogleDocsLib

struct DocumentExtractorTests {
    @Test
    func extractsTitleSummaryAndCodeBlocks() {
        let html = """
        <html>
        <head><title>ViewModel | Android Developers</title></head>
        <body>
          <h1>ViewModel</h1>
          <p>Stores and manages UI data.</p>
          <h2>Key points</h2>
          <p>Survives configuration changes.</p>
          <pre><code>class MainViewModel : ViewModel()</code></pre>
          <a href=\"/topic/libraries/architecture/livedata\">LiveData</a>
        </body>
        </html>
        """

        let page = DocumentExtractor.extract(
            from: html,
            url: "https://developer.android.com/topic/libraries/architecture/viewmodel",
            source: "android"
        )

        #expect(page.title == "ViewModel")
        #expect(page.summary == "Stores and manages UI data.")
        #expect(page.codeBlocks.count == 1)
        #expect(page.relatedLinks.count == 1)
    }
}
