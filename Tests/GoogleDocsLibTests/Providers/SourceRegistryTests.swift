import Testing
@testable import GoogleDocsLib

struct SourceRegistryTests {
    @Test
    func registryContainsDefaultSources() {
        let ids = Set(SourceRegistry.all.map(\.id))

        #expect(ids.contains("android"))
        #expect(ids.contains("kotlin"))
        #expect(ids.contains("jetpack"))
        #expect(ids.contains("google-play-services"))
        #expect(ids.contains("firebase-docs"))
        #expect(ids.contains("material-design"))
    }

    @Test
    func sourceDefinitionsExposeTaxonomyMetadata() {
        let android = SourceRegistry.definition(for: "android")

        #expect(android?.official == true)
        #expect(android?.kind == .reference)
    }

    @Test
    func sourceDefinitionsExposeRelevanceMetadata() {
        let android = SourceRegistry.definition(for: "android")
        let kotlin = SourceRegistry.definition(for: "kotlin")

        #expect(android?.preferredPathPrefixes.isEmpty == false)
        #expect(android?.blockedTitlePhrases.contains("skip to main content") == true)
        #expect(android?.blockedURLFragments.contains("#top") == true)

        #expect(kotlin?.preferredPathPrefixes.contains("/docs/") == true)
        #expect(kotlin?.blockedTitlePhrases.isEmpty == false)
        #expect(kotlin?.blockedURLFragments.isEmpty == false)
    }

    @Test
    func allSourcesHaveRelevanceDefaults() {
        for definition in SourceRegistry.all {
            #expect(definition.preferredPathPrefixes.isEmpty == false)
            #expect(definition.blockedTitlePhrases.isEmpty == false)
            #expect(definition.blockedURLFragments.isEmpty == false)
        }
    }

    @Test
    func unknownSourceReturnsNil() {
        #expect(SourceRegistry.definition(for: "missing") == nil)
    }
}
