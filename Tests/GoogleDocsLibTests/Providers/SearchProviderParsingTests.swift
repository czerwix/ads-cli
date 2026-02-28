import Testing
import Foundation
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
        #expect(results.first?.sourceId == "firebase-docs")
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

    @Test
    func parserInfersContentKindFromURLAndTitleHeuristics() {
        let html = """
        <html><body>
          <a href="/reference/androidx/navigation/NavController">NavController API</a>
          <a href="/guide/navigation/navigation-getting-started">Navigation guide</a>
          <a href="/topic/libraries/architecture/viewmodel">ViewModel topic</a>
          <a href="/tutorials/navigation/setup">Navigation tutorial</a>
          <a href="/codelabs/navigation">Navigation codelab</a>
          <a href="/samples/navigation/sample-app">Navigation sample app</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)
        let kindByTitle = Dictionary(uniqueKeysWithValues: results.map { ($0.title, $0.kind) })

        #expect(kindByTitle["NavController API"] == .reference)
        #expect(kindByTitle["Navigation guide"] == .guide)
        #expect(kindByTitle["ViewModel topic"] == .guide)
        #expect(kindByTitle["Navigation tutorial"] == .tutorial)
        #expect(kindByTitle["Navigation codelab"] == .tutorial)
        #expect(kindByTitle["Navigation sample app"] == .sample)
    }

    @Test
    func parserFallsBackToSourceDefaultKindWhenInferenceIsUnclear() {
        let html = """
        <html><body>
          <a href="/blog/navigation-updates">Navigation updates</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)

        #expect(results.count == 1)
        #expect(results.first?.kind == .reference)
    }

    @Test
    func parserFallsBackToUnknownKindWhenSourceIsUnknownAndInferenceIsUnclear() {
        let html = """
        <html><body>
          <a href="/blog/navigation-updates">Navigation updates</a>
        </body></html>
        """

        let results = SearchHTMLParser.parse(
            html: html,
            baseURL: "https://example.dev",
            source: "unknown-source",
            limit: 10
        )

        #expect(results.count == 1)
        #expect(results.first?.kind == .unknown)
    }

    @Test
    func androidParserParsesComplexFixtureWithSingleQuotedMultilineAnchor() throws {
        let html = try fixture(named: "android-search-results-complex")

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)

        #expect(results.count == 1)
        #expect(results.first?.url == "https://developer.android.com/topic/libraries/architecture/viewmodel")
        #expect(normalizeWhitespace(results.first?.title) == "ViewModel overview")
    }

    @Test
    func kotlinParserParsesComplexFixtureWithNoisyWrapperMarkup() throws {
        let html = try fixture(named: "kotlin-search-results-complex")

        let results = KotlinDocsProvider.parseSearchHTML(html, limit: 10)

        #expect(results.count == 1)
        #expect(results.first?.url == "https://kotlinlang.org/docs/coroutines-overview.html")
        #expect(normalizeWhitespace(results.first?.title) == "Coroutines overview")
    }

    @Test
    func androidParserSuppressesNavChromeTitlesFromFixture() throws {
        let html = try fixture(named: "android-search-results-with-nav-noise")

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)
        let titles = results.map(\.title)
        let urls = results.map(\.url)
        let docsPairs = Set(results.map { "\($0.url)|\($0.title)" })
        let expectedDocsPairs: Set<String> = [
            "https://developer.android.com/topic/libraries/architecture/viewmodel|ViewModel overview",
            "https://developer.android.com/topic/libraries/architecture/livedata|LiveData overview",
        ]

        #expect(results.count == 2)
        #expect(titles.contains("Skip to main content") == false)
        #expect(titles.contains("Change language") == false)
        #expect(urls.contains("https://developer.android.com/topic/libraries/architecture/viewmodel"))
        #expect(urls.contains("https://developer.android.com/topic/libraries/architecture/livedata"))
        #expect(docsPairs == expectedDocsPairs)
    }

    @Test
    func kotlinParserTreatsMixedFixtureAsNoisePlusLegitimateDocsResults() throws {
        let html = try fixture(named: "kotlin-search-results-mixed-relevance")

        let results = KotlinDocsProvider.parseSearchHTML(html, limit: 10)
        let urls = results.map(\.url)
        let expectedURLs: Set<String> = [
            "https://kotlinlang.org/docs/coroutines-overview.html",
            "https://kotlinlang.org/docs/coroutines-basics.html",
        ]

        #expect(results.count == 2)
        #expect(urls.contains("https://kotlinlang.org#content") == false)
        #expect(urls.contains("https://kotlinlang.org?query=coroutines") == false)
        #expect(urls.contains("https://kotlinlang.org/docs/coroutines-overview.html"))
        #expect(urls.contains("https://kotlinlang.org/docs/coroutines-basics.html"))
        #expect(Set(urls) == expectedURLs)
    }

    @Test
    func parserIgnoresMalformedHref() {
        let html = """
        <html><body>
          <a href=\"http://[::1\">Broken</a>
          <a href=\"/topic/libraries/architecture/viewmodel\">ViewModel overview</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)

        #expect(results.count == 1)
        #expect(results.first?.title == "ViewModel overview")
        #expect(results.first?.url == "https://developer.android.com/topic/libraries/architecture/viewmodel")
    }

    @Test
    func parserDoesNotTreatDataHrefAsHrefAttribute() {
        let html = """
        <html><body>
          <a data-href=\"/topic/libraries/architecture/viewmodel\">Fake match</a>
          <a href=\"/topic/libraries/architecture/livedata\">LiveData overview</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)

        #expect(results.count == 1)
        #expect(results.first?.title == "LiveData overview")
        #expect(results.first?.url == "https://developer.android.com/topic/libraries/architecture/livedata")
    }

    @Test
    func parserKeepsLateRelevantResultDespiteLargeEarlyNoiseBlock() {
        let noiseLinks = (1...30).map { index in
            "<a href=\"/blog/noise-\(index)\">Noise \(index)</a>"
        }.joined()

        let html = """
        <html><body>
          \(noiseLinks)
          <a href=\"/topic/libraries/architecture/viewmodel\">ViewModel overview</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 1)

        #expect(results.count == 1)
        #expect(results.first?.title == "ViewModel overview")
        #expect(results.first?.url == "https://developer.android.com/topic/libraries/architecture/viewmodel")
    }

    @Test
    func parserIgnoresEmptyAnchorText() {
        let html = """
        <html><body>
          <a href=\"/topic/empty\"><span>   </span></a>
          <a href=\"/topic/libraries/architecture/viewmodel\">ViewModel overview</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)

        #expect(results.count == 1)
        #expect(results.first?.title == "ViewModel overview")
    }

    @Test
    func parserResolvesRelativeAbsoluteProtocolRelativeAndQueryLinks() {
        let html = """
        <html><body>
          <a href=\"/topic/libraries/architecture/viewmodel\">Relative root</a>
          <a href=\"https://developer.android.com/jetpack\">Absolute</a>
          <a href=\"//developer.android.com/reference\">Protocol relative</a>
          <a href=\"?hl=en\">Query only</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)
        let urls = results.map(\.url)
        let expectedURLs: Set<String> = [
            "https://developer.android.com/topic/libraries/architecture/viewmodel",
            "https://developer.android.com/jetpack",
            "https://developer.android.com/reference",
        ]

        #expect(results.count == 3)
        #expect(urls.contains("https://developer.android.com/topic/libraries/architecture/viewmodel"))
        #expect(urls.contains("https://developer.android.com/jetpack"))
        #expect(urls.contains("https://developer.android.com/reference"))
        #expect(Set(urls) == expectedURLs)
        #expect(results.contains { $0.url == "https://developer.android.com?hl=en" } == false)
    }

    @Test
    func parserScoresPreferredPathsHigherThanNonPreferredPaths() {
        let html = """
        <html><body>
          <a href=\"/blog/viewmodel-intro\">ViewModel intro</a>
          <a href=\"/topic/libraries/architecture/viewmodel\">ViewModel overview</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 10)

        let preferred = results.first { $0.url == "https://developer.android.com/topic/libraries/architecture/viewmodel" }
        let nonPreferred = results.first { $0.url == "https://developer.android.com/blog/viewmodel-intro" }

        #expect(preferred != nil)
        #expect(nonPreferred != nil)
        #expect(preferred?.score != 1.0)
        #expect(nonPreferred?.score != 1.0)
        #expect((preferred?.score ?? 0) > (nonPreferred?.score ?? 0))
    }

    @Test
    func parserWithQueryLetsStrongNonPreferredMatchOutrankWeakPreferredPathResult() {
        let html = """
        <html><body>
          <a href=\"/topic/libraries/architecture/viewmodel\">ViewModel architecture overview</a>
          <a href=\"/blog/viewmodel-savedstate-coroutines-flow\">ViewModel SavedState coroutines Flow deep dive</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(
            html,
            query: "viewmodel savedstate coroutines flow",
            limit: 1
        )

        #expect(results.count == 1)
        #expect(results.first?.url == "https://developer.android.com/blog/viewmodel-savedstate-coroutines-flow")
        #expect(results.first?.title == "ViewModel SavedState coroutines Flow deep dive")
    }

    @Test
    func parserWithQueryRequiresTokenMatchBeforeApplyingLimit() {
        let html = """
        <html><body>
          <a href=\"/topic/libraries/architecture/guide\">Architecture guide</a>
          <a href=\"/topic/libraries/architecture/viewmodel\">ViewModel overview</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, query: "viewmodel", limit: 1)

        #expect(results.count == 1)
        #expect(results.first?.title == "ViewModel overview")
        #expect(results.first?.url == "https://developer.android.com/topic/libraries/architecture/viewmodel")
    }

    @Test
    func parserWithoutQueryKeepsBackwardCompatibleSelection() {
        let html = """
        <html><body>
          <a href=\"/topic/libraries/architecture/guide\">Architecture guide</a>
          <a href=\"/topic/libraries/architecture/viewmodel\">ViewModel overview</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 1)

        #expect(results.count == 1)
        #expect(results.first?.title == "Architecture guide")
    }

    @Test
    func parserDoesNotDropLegitimateAuthTitlesContainingBlockedPhraseText() {
        let html = """
        <html><body>
          <a href="/accounts/sign-in">Sign in</a>
          <a href="/identity/sign-in-with-google">Sign in with Google</a>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, query: "google", limit: 10)

        #expect(results.count == 1)
        #expect(results.first?.title == "Sign in with Google")
        #expect(results.first?.url == "https://developer.android.com/identity/sign-in-with-google")
    }

    @Test
    func parserHonorsLimitWithRealisticInput() {
        let html = """
        <html><body>
          <section><a href=\"/topic/1\">Result 1</a></section>
          <section><a href=\"/topic/2\">Result 2</a></section>
          <section><a href=\"/topic/3\">Result 3</a></section>
          <section><a href=\"/topic/4\">Result 4</a></section>
          <section><a href=\"/topic/5\">Result 5</a></section>
        </body></html>
        """

        let results = AndroidDocsProvider.parseSearchHTML(html, limit: 3)

        #expect(results.count == 3)
        #expect(results[0].title == "Result 1")
        #expect(results[1].title == "Result 2")
        #expect(results[2].title == "Result 3")
    }

    private func fixture(named name: String) throws -> String {
        guard let fixtureURL = Bundle.module.url(
            forResource: name,
            withExtension: "html",
            subdirectory: "Fixtures/Search"
        ) else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try String(contentsOf: fixtureURL, encoding: .utf8)
    }

    private func normalizeWhitespace(_ value: String?) -> String {
        guard let value else { return "" }
        return value.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
