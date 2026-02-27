public enum SourceRegistry {
    public static let all: [SourceDefinition] = [
        SourceDefinition(id: "android", displayName: "Android Developers", kind: .reference, official: true),
        SourceDefinition(id: "kotlin", displayName: "Kotlin", kind: .reference, official: true),
        SourceDefinition(id: "jetpack", displayName: "Jetpack", kind: .reference, official: true)
    ]

    public static func definition(for sourceId: String) -> SourceDefinition? {
        all.first { $0.id == sourceId }
    }
}
