public struct DocumentSection: Codable, Equatable, Sendable {
    public let title: String
    public let body: String

    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}

public struct DocumentPage: Codable, Equatable, Sendable {
    public let title: String
    public let url: String
    public let summary: String
    public let sections: [DocumentSection]
    public let codeBlocks: [String]
    public let relatedLinks: [RelatedTopic]
    public let metadata: [String: String]

    public init(
        title: String,
        url: String,
        summary: String,
        sections: [DocumentSection],
        codeBlocks: [String],
        relatedLinks: [RelatedTopic],
        metadata: [String: String]
    ) {
        self.title = title
        self.url = url
        self.summary = summary
        self.sections = sections
        self.codeBlocks = codeBlocks
        self.relatedLinks = relatedLinks
        self.metadata = metadata
    }
}
