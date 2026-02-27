import Foundation

public enum RelatedExtractor {
    public static func extract(from html: String, baseURL: String) -> [RelatedTopic] {
        let pattern = #"<a\s+[^>]*href=\"([^\"]+)\"[^>]*>(.*?)</a>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return []
        }

        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        let matches = regex.matches(in: html, options: [], range: range)
        var topics: [RelatedTopic] = []

        for match in matches {
            guard match.numberOfRanges == 3,
                  let hrefRange = Range(match.range(at: 1), in: html),
                  let titleRange = Range(match.range(at: 2), in: html)
            else {
                continue
            }

            let href = String(html[hrefRange])
            let title = HTMLTextExtractor.clean(String(html[titleRange]))
            if title.isEmpty {
                continue
            }

            let resolvedURL = resolveURL(href: href, baseURL: baseURL)
            topics.append(RelatedTopic(title: title, url: resolvedURL))
            if topics.count >= 10 {
                break
            }
        }

        return topics
    }

    private static func resolveURL(href: String, baseURL: String) -> String {
        if href.hasPrefix("http://") || href.hasPrefix("https://") {
            return href
        }

        guard let base = URL(string: baseURL),
              let host = base.host,
              let scheme = base.scheme
        else {
            return href
        }

        if href.hasPrefix("/") {
            return "\(scheme)://\(host)\(href)"
        }

        return "\(scheme)://\(host)/\(href)"
    }
}
