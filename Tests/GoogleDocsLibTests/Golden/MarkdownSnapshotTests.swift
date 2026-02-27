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
            "## AI Skill",
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
            "ads search \"navigation\" --source android --kind guide",
            "ads sources",
            "ads doc \"topic/libraries/architecture/viewmodel\"",
            "ads related \"topic/libraries/architecture/viewmodel\"",
            "ads platform \"topic/libraries/architecture/viewmodel\"",
            "ads frameworks --filter compose",
            "ads search \"viewmodel\" --limit 5 --json",
            "ads search \"viewmodel\" --source android --json",
            "ads search \"navigation\" --kind guide --json",
            "ads sources --json",
            "ads frameworks --json"
        ]

        for example in requiredCommandExamples {
            #expect(readme.contains(example), "Missing README command example: \(example)")
        }
    }

    @Test
    func aiSkillDocsSnapshot() throws {
        let root = try repoRootURL()
        let aiSkillDoc = try String(
            contentsOf: root.appendingPathComponent("docs/ai-skill.md"),
            encoding: .utf8
        )
        let skillDoc = try String(
            contentsOf: root.appendingPathComponent("skill/SKILL.md"),
            encoding: .utf8
        )

        let aiSkillDocRequiredContent = [
            "OpenCode",
            "Claude Code",
            "Codex CLI",
            "ads sources --json",
            "ads search \"viewmodel\" --source android --json",
            "ads search \"navigation\" --kind guide --json",
            "ads doc \"topic/libraries/architecture/viewmodel\" --json",
            "ads related \"topic/libraries/architecture/viewmodel\" --json",
            "ads platform \"topic/libraries/architecture/viewmodel\" --json",
            "ads frameworks --json"
        ]

        for entry in aiSkillDocRequiredContent {
            #expect(aiSkillDoc.contains(entry), "Missing AI skill docs content: \(entry)")
        }

        let skillDocRequiredContent = [
            "`ads sources --json`",
            "`ads search \"<query>\" --source android --json`",
            "`ads search \"<query>\" --kind guide --json`",
            "`ads doc \"<path-or-url>\" --json`",
            "`ads related \"<path-or-url>\" --json`",
            "`ads platform \"<path-or-url>\" --json`",
            "`ads frameworks --json`"
        ]

        for entry in skillDocRequiredContent {
            #expect(skillDoc.contains(entry), "Missing skill file content: \(entry)")
        }
    }

    private func readmeURL() throws -> URL {
        try repoRootURL().appendingPathComponent("README.md")
    }

    private func repoRootURL() throws -> URL {
        let fileManager = FileManager.default
        var current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

        while true {
            let packageSwiftURL = current.appendingPathComponent("Package.swift")
            if fileManager.fileExists(atPath: packageSwiftURL.path) {
                return current
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
