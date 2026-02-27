import Foundation

public struct FirebaseDocsProvider: DocsProvider {
    public let source = "firebase"

    public init() {}

    public func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://firebase.google.com/search?query=\(encoded)")!
        let response = try await client.get(url: url)
        let html = String(decoding: response.data, as: UTF8.self)
        return Self.parseSearchHTML(html, limit: limit)
    }

    public func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        let url = URL(string: pathOrURL.hasPrefix("http") ? pathOrURL : "https://firebase.google.com/\(pathOrURL)")!
        let response = try await client.get(url: url)
        let html = String(decoding: response.data, as: UTF8.self)
        return DocumentExtractor.extract(from: html, url: url.absoluteString, source: source)
    }

    public static func parseSearchHTML(_ html: String, limit: Int) -> [SearchResult] {
        SearchHTMLParser.parse(html: html, baseURL: "https://firebase.google.com", source: "firebase", limit: limit)
    }
}
