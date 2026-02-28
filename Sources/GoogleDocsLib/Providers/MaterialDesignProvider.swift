import Foundation

public struct MaterialDesignProvider: DocsProvider {
    public let source = "material-design"

    public init() {}

    public func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://m3.material.io/search?q=\(encoded)")!
        let response = try await client.get(url: url)
        let html = String(decoding: response.data, as: UTF8.self)
        return Self.parseSearchHTML(html, query: query, limit: limit)
    }

    public func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        let url = URL(string: pathOrURL.hasPrefix("http") ? pathOrURL : "https://m3.material.io/\(pathOrURL)")!
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
            baseURL: "https://m3.material.io",
            source: "material-design",
            query: query,
            limit: limit
        )
    }
}
