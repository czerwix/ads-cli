public struct SearchResult: Codable, Equatable, Sendable {
    public let title: String
    public let url: String
    public let snippet: String
    public let source: String
    public let score: Double

    public init(title: String, url: String, snippet: String, source: String, score: Double) {
        self.title = title
        self.url = url
        self.snippet = snippet
        self.source = source
        self.score = score
    }
}
