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

    private enum CodingKeys: String, CodingKey {
        case title
        case url
        case snippet
        case source
        case sourceId
        case kind
        case official
        case score
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let title = try container.decode(String.self, forKey: .title)
        let url = try container.decode(String.self, forKey: .url)
        let snippet = try container.decode(String.self, forKey: .snippet)
        let source = try container.decode(String.self, forKey: .source)
        let score = try container.decode(Double.self, forKey: .score)
        let sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId) ?? source
        let kind = try container.decodeIfPresent(ContentKind.self, forKey: .kind) ?? .unknown
        let official = try container.decodeIfPresent(Bool.self, forKey: .official) ?? false

        self.init(
            title: title,
            url: url,
            snippet: snippet,
            source: source,
            score: score,
            sourceId: sourceId,
            kind: kind,
            official: official
        )
    }
}
