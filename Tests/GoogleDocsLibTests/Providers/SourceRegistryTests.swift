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
    func unknownSourceReturnsNil() {
        #expect(SourceRegistry.definition(for: "missing") == nil)
    }
}
