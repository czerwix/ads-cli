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

    @Test
    func googlePlayServicesParserExtractsMetadataFromSourceRegistry() {
        let html = """
        <html><body>
          <a href=\"/android/reference/com/google/android/gms/ads/AdView\">AdView</a>
        </body></html>
        """

        let results = GooglePlayServicesProvider.parseSearchHTML(html, limit: 5)

        #expect(results.count == 1)
        #expect(results.first?.url == "https://developers.google.com/android/reference/com/google/android/gms/ads/AdView")
        #expect(results.first?.sourceId == "google-play-services")
        #expect(results.first?.kind == .reference)
        #expect(results.first?.official == true)
    }

    @Test
    func firebaseParserExtractsMetadataFromSourceRegistry() {
        let html = """
        <html><body>
          <a href=\"/docs/crashlytics/get-started\">Crashlytics get started</a>
        </body></html>
        """

        let results = FirebaseDocsProvider.parseSearchHTML(html, limit: 5)

        #expect(results.count == 1)
        #expect(results.first?.url == "https://firebase.google.com/docs/crashlytics/get-started")
        #expect(results.first?.sourceId == "firebase")
        #expect(results.first?.kind == .reference)
        #expect(results.first?.official == true)
    }

    @Test
    func materialDesignParserExtractsMetadataFromSourceRegistry() {
        let html = """
        <html><body>
          <a href=\"/components/buttons/overview\">Buttons</a>
        </body></html>
        """

        let results = MaterialDesignProvider.parseSearchHTML(html, limit: 5)

        #expect(results.count == 1)
        #expect(results.first?.url == "https://m3.material.io/components/buttons/overview")
        #expect(results.first?.sourceId == "material-design")
        #expect(results.first?.kind == .reference)
        #expect(results.first?.official == true)
    }
}
