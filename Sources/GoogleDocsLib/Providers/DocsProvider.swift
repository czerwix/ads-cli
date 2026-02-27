public protocol DocsProvider: Sendable {
    var source: String { get }

    func search(query: String, limit: Int, client: HTTPClient) async throws -> [SearchResult]
    func doc(pathOrURL: String, client: HTTPClient) async throws -> DocumentPage
}
