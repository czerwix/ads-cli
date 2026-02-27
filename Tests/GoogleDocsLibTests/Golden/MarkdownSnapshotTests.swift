import Testing
import Foundation
@testable import GoogleDocsLib

struct MarkdownSnapshotTests {
    @Test
    func searchMarkdownSnapshot() {
        let output = MarkdownRenderer.renderSearchResults(
            "compose",
            [
                SearchResult(
                    title: "Compose docs",
                    url: "https://developer.android.com/develop/ui/compose",
                    snippet: "Declarative UI toolkit",
                    source: "android",
                    score: 1.0
                )
            ]
        )

        let expected = """
        # Search Results for \"compose\"

        ## 1. Compose docs
        - URL: https://developer.android.com/develop/ui/compose
        - Source: android
        - Snippet: Declarative UI toolkit

        """

        #expect(output == expected)
    }

    @Test
    func readmeUsageSectionsSnapshot() throws {
        let readme = try String(contentsOf: readmeURL(), encoding: .utf8)

        let requiredSections = [
            "## Install",
            "## Build And Run",
            "## Command Surface",
            "## Human CLI Usage",
            "## AI-Agent Usage",
            "## Scope And Direction"
        ]

        var previousStart = readme.startIndex
        for section in requiredSections {
            guard let range = readme.range(of: section, range: previousStart..<readme.endIndex) else {
                #expect(Bool(false), "Missing README section: \(section)")
                return
            }
            previousStart = range.upperBound
        }

        let requiredCommandExamples = [
            "swift build -c release",
            "swift run ads --help",
            ".build/release/ads search \"compose\"",
            "ads search \"viewmodel\" --limit 5",
            "ads doc \"topic/libraries/architecture/viewmodel\"",
            "ads related \"topic/libraries/architecture/viewmodel\"",
            "ads platform \"topic/libraries/architecture/viewmodel\"",
            "ads frameworks --filter compose",
            "ads search \"viewmodel\" --limit 5 --json",
            "ads frameworks --json"
        ]

        for example in requiredCommandExamples {
            #expect(readme.contains(example), "Missing README command example: \(example)")
        }
    }

    private func readmeURL() throws -> URL {
        let fileManager = FileManager.default
        var current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

        while true {
            let packageSwiftURL = current.appendingPathComponent("Package.swift")
            let readmeURL = current.appendingPathComponent("README.md")
            if fileManager.fileExists(atPath: packageSwiftURL.path),
               fileManager.fileExists(atPath: readmeURL.path) {
                return readmeURL
            }

            let parent = current.deletingLastPathComponent()
            if parent == current {
                break
            }
            current = parent
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
