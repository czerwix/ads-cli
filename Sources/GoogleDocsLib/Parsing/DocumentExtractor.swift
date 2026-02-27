import Foundation

public enum DocumentExtractor {
    public static func extract(from html: String, url: String, source: String) -> DocumentPage {
        let title =
            HTMLTextExtractor.firstMatch(in: html, pattern: #"<h1[^>]*>(.*?)</h1>"#)
            ?? HTMLTextExtractor.firstMatch(in: html, pattern: #"<title[^>]*>(.*?)</title>"#)
            ?? "Untitled"

        let summary =
            HTMLTextExtractor.firstMatch(in: html, pattern: #"<p[^>]*>(.*?)</p>"#)
            ?? "No summary available."

        let sections = extractSections(from: html)
        let codeBlocks = HTMLTextExtractor.allMatches(in: html, pattern: #"<pre[^>]*><code[^>]*>(.*?)</code></pre>"#)
        let relatedLinks = RelatedExtractor.extract(from: html, baseURL: url)
        let metadata = PlatformExtractor.extractMetadata(from: html)
            .merging(["source": source], uniquingKeysWith: { current, _ in current })

        return DocumentPage(
            title: title,
            url: url,
            summary: summary,
            sections: sections,
            codeBlocks: codeBlocks,
            relatedLinks: relatedLinks,
            metadata: metadata
        )
    }

    private static func extractSections(from html: String) -> [DocumentSection] {
        let pattern = #"<h2[^>]*>(.*?)</h2>\s*<p[^>]*>(.*?)</p>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return []
        }

        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        let matches = regex.matches(in: html, options: [], range: range)

        return matches.compactMap { match in
            guard match.numberOfRanges > 2,
                  let titleRange = Range(match.range(at: 1), in: html),
                  let bodyRange = Range(match.range(at: 2), in: html)
            else {
                return nil
            }

            return DocumentSection(
                title: HTMLTextExtractor.clean(String(html[titleRange])),
                body: HTMLTextExtractor.clean(String(html[bodyRange]))
            )
        }
    }
}
