import Foundation

public struct JetpackDocsProvider: DocsProvider {
    public let source = "jetpack"

    public init() {}

    public func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        let encoded = ("androidx \(query)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://developer.android.com/s/results?q=\(encoded)")!
        let response = try await client.get(url: url)
        let html = String(decoding: response.data, as: UTF8.self)
        return Self.parseSearchHTML(html, query: query, limit: limit)
    }

    public func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        let url = URL(string: pathOrURL.hasPrefix("http") ? pathOrURL : "https://developer.android.com/jetpack/\(pathOrURL)")!
        let response = try await client.get(url: url)
        let html = String(decoding: response.data, as: UTF8.self)
        return DocumentExtractor.extract(from: html, url: url.absoluteString, source: source)
    }

    public static func parseSearchHTML(_ html: String, limit: Int) -> [SearchResult] {
        parseSearchHTML(html, query: nil, limit: limit)
    }

    public static func parseSearchHTML(_ html: String, query: String?, limit: Int) -> [SearchResult] {
        SearchHTMLParser.parse(
            html: html,
            baseURL: "https://developer.android.com",
            source: "jetpack",
            query: query,
            limit: limit
        )
    }
}
