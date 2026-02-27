public struct SearchResult: Codable, Equatable, Sendable {
    public let title: String
    public let url: String
    public let snippet: String
    public let source: String
    public let sourceId: String
    public let kind: ContentKind
    public let official: Bool
    public let score: Double

    public init(
        title: String,
        url: String,
        snippet: String,
        source: String,
        score: Double,
        sourceId: String? = nil,
        kind: ContentKind = .unknown,
        official: Bool = false
    ) {
        self.title = title
        self.url = url
        self.snippet = snippet
        self.source = source
        self.sourceId = sourceId ?? source
        self.kind = kind
        self.official = official
        self.score = score
    }
}
