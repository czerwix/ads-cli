public enum MarkdownRenderer {
    public static func renderSearchResults(_ query: String, _ results: [SearchResult]) -> String {
        var lines = ["# Search Results for \"\(query)\"", ""]

        if results.isEmpty {
            lines.append("No results found.")
            return lines.joined(separator: "\n")
        }

        for (index, result) in results.enumerated() {
            lines.append("## \(index + 1). \(result.title)")
            lines.append("- URL: \(result.url)")
            lines.append("- Source: \(result.source)")
            lines.append("- Snippet: \(result.snippet)")
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }

    public static func renderDocument(_ page: DocumentPage) -> String {
        var lines = ["# \(page.title)", "", page.summary, "", "- URL: \(page.url)", ""]

        for section in page.sections {
            lines.append("## \(section.title)")
            lines.append(section.body)
            lines.append("")
        }

        if !page.codeBlocks.isEmpty {
            lines.append("## Code")
            for block in page.codeBlocks {
                lines.append("```kotlin")
                lines.append(block)
                lines.append("```")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }
}
