import Foundation

public struct GooglePlayServicesProvider: DocsProvider {
    public let source = "google-play-services"

    public init() {}

    public func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult] {
        let encoded = ("google play services \(query)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://developers.google.com/s/results?q=\(encoded)")!
        let response = try await client.get(url: url)
        let html = String(decoding: response.data, as: UTF8.self)
        return Self.parseSearchHTML(html, limit: limit)
    }

    public func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage {
        let url = URL(string: pathOrURL.hasPrefix("http") ? pathOrURL : "https://developers.google.com/android/reference/\(pathOrURL)")!
        let response = try await client.get(url: url)
        let html = String(decoding: response.data, as: UTF8.self)
        return DocumentExtractor.extract(from: html, url: url.absoluteString, source: source)
    }

    public static func parseSearchHTML(_ html: String, limit: Int) -> [SearchResult] {
        SearchHTMLParser.parse(html: html, baseURL: "https://developers.google.com", source: "google-play-services", limit: limit)
    }
}
