public struct SourceDefinition: Codable, Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let kind: ContentKind
    public let official: Bool
    public let preferredPathPrefixes: [String]
    public let blockedTitlePhrases: [String]
    public let blockedURLFragments: [String]

    public init(
        id: String,
        displayName: String,
        kind: ContentKind,
        official: Bool,
        preferredPathPrefixes: [String] = [],
        blockedTitlePhrases: [String] = [],
        blockedURLFragments: [String] = []
    ) {
        self.id = id
        self.displayName = displayName
        self.kind = kind
        self.official = official
        self.preferredPathPrefixes = preferredPathPrefixes
        self.blockedTitlePhrases = blockedTitlePhrases
        self.blockedURLFragments = blockedURLFragments
    }
}
