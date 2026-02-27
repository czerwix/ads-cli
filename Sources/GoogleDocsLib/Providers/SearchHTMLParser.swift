import Foundation

enum SearchHTMLParser {
    static func parse(
        html: String,
        baseURL: String,
        source: String,
        limit: Int
    ) -> [SearchResult] {
        let pattern = #"<a\s+[^>]*href=\"([^\"]+)\"[^>]*>(.*?)</a>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return []
        }

        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        let matches = regex.matches(in: html, options: [], range: range)
        let sourceDefinition = SourceRegistry.definition(for: source)

        var items: [SearchResult] = []

        for match in matches {
            guard match.numberOfRanges == 3,
                  let hrefRange = Range(match.range(at: 1), in: html),
                  let titleRange = Range(match.range(at: 2), in: html)
            else {
                continue
            }

            let href = String(html[hrefRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            let title = stripHTML(String(html[titleRange])).trimmingCharacters(in: .whitespacesAndNewlines)

            if title.isEmpty {
                continue
            }

            let resolvedURL = resolve(href: href, baseURL: baseURL)
            if resolvedURL.isEmpty {
                continue
            }

            items.append(
                SearchResult(
                    title: title,
                    url: resolvedURL,
                    snippet: "",
                    source: source,
                    score: 1.0,
                    kind: sourceDefinition?.kind ?? .unknown,
                    official: sourceDefinition?.official ?? false
                )
            )

            if items.count == limit {
                break
            }
        }

        return items
    }

    private static func stripHTML(_ value: String) -> String {
        value.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
    }

    private static func resolve(href: String, baseURL: String) -> String {
        if href.hasPrefix("http://") || href.hasPrefix("https://") {
            return href
        }
        if href.hasPrefix("/") {
            return baseURL + href
        }
        return baseURL + "/" + href
    }
}
