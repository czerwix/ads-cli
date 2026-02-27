import Testing
@testable import GoogleDocsLib

struct SearchProviderParsingTests {
    @Test
    func androidParserExtractsLinkAndTitle() {
        let html = """
        <html><body>
          <a href=\"/topic/libraries/architecture/viewmodel\">ViewModel overview</a>
          <p>Store and manage UI-related data.</p>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)

        #expect(results.count == 1)
        #expect(results.first?.title == "ViewModel overview")
        #expect(results.first?.url == "https://developer.android.com/topic/libraries/architecture/viewmodel")
    }

    @Test
    func kotlinParserExtractsAbsoluteLinks() {
        let html = """
        <html><body>
          <a href=\"https://kotlinlang.org/docs/coroutines-overview.html\">Coroutines overview</a>
        </body></html>
        """

        let results = KotlinDocsProvider.parseSearchHTML(html, limit: 5)

        #expect(results.count == 1)
        #expect(results.first?.url == "https://kotlinlang.org/docs/coroutines-overview.html")
    }
}
