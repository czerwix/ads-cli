public struct SourceDefinition: Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let kind: ContentKind
    public let official: Bool

    public init(id: String, displayName: String, kind: ContentKind, official: Bool) {
        self.id = id
        self.displayName = displayName
        self.kind = kind
        self.official = official
    }
}
