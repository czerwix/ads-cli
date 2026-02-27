import Foundation

public struct KotlinDocsProvider: DocsProvider {
    public let source = "kotlin"

    public init() {}

    public func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://kotlinlang.org/docs/search.html?q=\(encoded)")!
        let response = try await client.get(url: url)
        let html = String(decoding: response.data, as: UTF8.self)
        return Self.parseSearchHTML(html, limit: limit)
    }

    public func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        let url: URL
        if pathOrURL.hasPrefix("http") {
            url = URL(string: pathOrURL)!
        } else {
            let normalized = pathOrURL.hasSuffix(".html") ? pathOrURL : "\(pathOrURL).html"
            url = URL(string: "https://kotlinlang.org/docs/\(normalized)")!
        }

        let response = try await client.get(url: url)
        let html = String(decoding: response.data, as: UTF8.self)
        return DocumentExtractor.extract(from: html, url: url.absoluteString, source: source)
    }

    public static func parseSearchHTML(_ html: String, limit: Int) -> [SearchResult] {
        SearchHTMLParser.parse(html: html, baseURL: "https://kotlinlang.org", source: "kotlin", limit: limit)
    }
}
