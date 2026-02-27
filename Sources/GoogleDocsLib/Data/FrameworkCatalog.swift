public struct FrameworkEntry: Codable, Equatable, Sendable {
    public let name: String
    public let slug: String
    public let description: String

    public init(name: String, slug: String, description: String) {
        self.name = name
        self.slug = slug
        self.description = description
    }
}

public enum FrameworkCatalog {
    public static let all: [FrameworkEntry] = [
        FrameworkEntry(name: "Android Framework", slug: "android", description: "Core Android platform APIs."),
        FrameworkEntry(name: "Jetpack Compose", slug: "compose", description: "Declarative UI toolkit for Android."),
        FrameworkEntry(name: "AndroidX Lifecycle", slug: "lifecycle", description: "Lifecycle-aware components and ViewModel."),
        FrameworkEntry(name: "Kotlin Standard Library", slug: "kotlin", description: "Kotlin language core APIs.")
    ]
}
