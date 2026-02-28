public enum SourceRegistry {
    private static let commonBlockedTitlePhrases: [String] = [
        "skip to main content",
        "main navigation",
        "open search",
        "sign in",
        "back to top"
    ]

    private static let commonBlockedURLFragments: [String] = [
        "#main-content",
        "#content",
        "#top",
        "?authuser=",
        "utm_"
    ]

    public static let all: [SourceDefinition] = [
        SourceDefinition(
            id: "android",
            displayName: "Android Developers",
            kind: .reference,
            official: true,
            preferredPathPrefixes: ["/topic", "/guide", "/reference", "/develop", "/training", "/studio"],
            blockedTitlePhrases: commonBlockedTitlePhrases,
            blockedURLFragments: commonBlockedURLFragments
        ),
        SourceDefinition(
            id: "kotlin",
            displayName: "Kotlin",
            kind: .reference,
            official: true,
            preferredPathPrefixes: ["/docs/", "/api/"],
            blockedTitlePhrases: commonBlockedTitlePhrases,
            blockedURLFragments: commonBlockedURLFragments
        ),
        SourceDefinition(
            id: "jetpack",
            displayName: "Jetpack",
            kind: .reference,
            official: true,
            preferredPathPrefixes: ["/jetpack", "/topic", "/guide", "/reference/androidx", "/reference/kotlin"],
            blockedTitlePhrases: commonBlockedTitlePhrases,
            blockedURLFragments: commonBlockedURLFragments
        ),
        SourceDefinition(
            id: "google-play-services",
            displayName: "Google Play Services",
            kind: .reference,
            official: true,
            preferredPathPrefixes: ["/android/reference", "/identity", "/maps", "/location"],
            blockedTitlePhrases: commonBlockedTitlePhrases,
            blockedURLFragments: commonBlockedURLFragments
        ),
        SourceDefinition(
            id: "firebase-docs",
            displayName: "Firebase",
            kind: .reference,
            official: true,
            preferredPathPrefixes: ["/docs/", "/support/", "/codelabs/"],
            blockedTitlePhrases: commonBlockedTitlePhrases,
            blockedURLFragments: commonBlockedURLFragments
        ),
        SourceDefinition(
            id: "material-design",
            displayName: "Material Design",
            kind: .reference,
            official: true,
            preferredPathPrefixes: ["/components", "/styles", "/foundations", "/develop"],
            blockedTitlePhrases: commonBlockedTitlePhrases,
            blockedURLFragments: commonBlockedURLFragments
        )
    ]

    public static func definition(for sourceId: String) -> SourceDefinition? {
        all.first { $0.id == sourceId }
    }
}
