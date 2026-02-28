import Foundation

enum SearchHTMLParser {
    static func parse(
        html: String,
        baseURL: String,
        source: String,
        query: String? = nil,
        limit: Int
    ) -> [SearchResult] {
        guard limit > 0, !html.isEmpty else {
            return []
        }

        let pattern = #"<a\b[^>]*?(?:\s|^)href\s*=\s*(['\"])(.*?)\1[^>]*>(.*?)</a>"#
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        ) else {
            return []
        }

        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        let sourceDefinition = SourceRegistry.definition(for: source)
        let queryTokens = tokenize(query ?? "")

        var scoredItems: [ScoredResult] = []
        var anchorOrder = 0

        regex.enumerateMatches(in: html, options: [], range: range) { match, _, _ in
            guard let match else {
                return
            }

            guard match.numberOfRanges == 4,
                  let hrefRange = Range(match.range(at: 2), in: html),
                  let titleRange = Range(match.range(at: 3), in: html)
            else {
                return
            }

            let href = String(html[hrefRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            let title = stripHTML(String(html[titleRange])).trimmingCharacters(in: .whitespacesAndNewlines)
            let blockedTitlePhrases = sourceDefinition?.blockedTitlePhrases ?? []
            let blockedURLFragments = sourceDefinition?.blockedURLFragments ?? []
            let preferredPathPrefixes = sourceDefinition?.preferredPathPrefixes ?? []

            if title.isEmpty || containsBlockedTitlePhrase(title, blockedPhrases: blockedTitlePhrases) {
                return
            }

            if isChromeHrefPattern(href) {
                return
            }

            guard let resolvedURL = resolve(href: href, baseURL: baseURL) else {
                return
            }

            if containsBlockedURLFragment(href: href, resolvedURL: resolvedURL, blockedFragments: blockedURLFragments) {
                return
            }

            let prefersPath = isPreferredPath(resolvedURL, preferredPathPrefixes: preferredPathPrefixes)
            let queryMatchCount = queryTokenMatchCount(
                queryTokens: queryTokens,
                title: title,
                resolvedURL: resolvedURL
            )

            if !queryTokens.isEmpty && queryMatchCount == 0 {
                return
            }

            let score = relevanceScore(
                title: title,
                resolvedURL: resolvedURL,
                prefersPath: prefersPath,
                hasPreferredPathPrefixes: !preferredPathPrefixes.isEmpty,
                queryMatchCount: queryMatchCount
            )

            scoredItems.append(
                ScoredResult(
                    order: anchorOrder,
                    prefersPath: prefersPath,
                    result: SearchResult(
                        title: title,
                        url: resolvedURL.absoluteString,
                        snippet: "",
                        source: source,
                        score: score,
                        kind: inferredKind(
                            resolvedURL: resolvedURL,
                            title: title,
                            fallback: sourceDefinition?.kind ?? .unknown
                        ),
                        official: sourceDefinition?.official ?? false
                    )
                )
            )
            anchorOrder += 1

        }

        let ordered = scoredItems.sorted { lhs, rhs in
            if lhs.result.score != rhs.result.score {
                return lhs.result.score > rhs.result.score
            }

            if lhs.prefersPath != rhs.prefersPath {
                return lhs.prefersPath && !rhs.prefersPath
            }

            return lhs.order < rhs.order
        }

        return Array(ordered.prefix(limit).map(\.result))
    }

    private static func stripHTML(_ value: String) -> String {
        let withoutTags = value.replacingOccurrences(of: #"<[^>]+>"#, with: " ", options: .regularExpression)
        return withoutTags.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }

    private static func resolve(href: String, baseURL: String) -> URL? {
        guard !href.isEmpty,
              let base = URL(string: baseURL),
              let resolved = URL(string: href, relativeTo: base)?.absoluteURL,
              let scheme = resolved.scheme?.lowercased(),
              scheme == "http" || scheme == "https"
        else {
            return nil
        }

        return resolved
    }

    private static func containsBlockedTitlePhrase(_ title: String, blockedPhrases: [String]) -> Bool {
        guard !blockedPhrases.isEmpty else {
            return false
        }

        let normalizedTitle = normalizeBlockedTitleValue(title)
        return blockedPhrases.contains { blockedPhrase in
            normalizedTitle == normalizeBlockedTitleValue(blockedPhrase)
        }
    }

    private static func normalizeBlockedTitleValue(_ value: String) -> String {
        value.lowercased().split { character in
            !character.isLetter && !character.isNumber
        }.map(String.init).joined(separator: " ")
    }

    private static func containsBlockedURLFragment(href: String, resolvedURL: URL, blockedFragments: [String]) -> Bool {
        guard !blockedFragments.isEmpty else {
            return false
        }

        let normalizedHref = href.lowercased()
        let normalizedResolvedURL = resolvedURL.absoluteString.lowercased()

        return blockedFragments.contains { fragment in
            let normalizedFragment = fragment.lowercased()
            return normalizedHref.contains(normalizedFragment) || normalizedResolvedURL.contains(normalizedFragment)
        }
    }

    private static func isChromeHrefPattern(_ href: String) -> Bool {
        let normalizedHref = href.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedHref.isEmpty else {
            return true
        }

        if normalizedHref.hasPrefix("#") || normalizedHref.hasPrefix("?") {
            return true
        }

        return normalizedHref.hasPrefix("javascript:")
            || normalizedHref.hasPrefix("mailto:")
            || normalizedHref.hasPrefix("tel:")
    }

    private static func isPreferredPath(_ url: URL, preferredPathPrefixes: [String]) -> Bool {
        guard !preferredPathPrefixes.isEmpty else {
            return false
        }

        let normalizedPath = url.path.lowercased()
        return preferredPathPrefixes.contains { prefix in
            normalizedPath.hasPrefix(prefix.lowercased())
        }
    }

    private static func relevanceScore(
        title: String,
        resolvedURL: URL,
        prefersPath: Bool,
        hasPreferredPathPrefixes: Bool,
        queryMatchCount: Int
    ) -> Double {
        let titleTokens = tokenize(title)
        let urlTokens = tokenize(resolvedURL.path + " " + (resolvedURL.query ?? ""))
        let sharedTokens = titleTokens.intersection(urlTokens)

        var score = hasPreferredPathPrefixes ? (prefersPath ? 2.0 : 0.5) : 1.0
        score += min(Double(sharedTokens.count) * 0.4, 1.6)

        let pathDepth = resolvedURL.pathComponents.filter { $0 != "/" }.count
        score += min(Double(pathDepth) * 0.05, 0.5)

        if resolvedURL.query != nil {
            score -= 0.1
        }

        if resolvedURL.fragment != nil {
            score -= 0.1
        }

        score += min(Double(queryMatchCount) * 1.2, 4.8)

        return max(score, 0)
    }

    private static func queryTokenMatchCount(
        queryTokens: Set<String>,
        title: String,
        resolvedURL: URL
    ) -> Int {
        guard !queryTokens.isEmpty else {
            return 0
        }

        let candidateTokens = tokenize(title + " " + resolvedURL.path + " " + (resolvedURL.query ?? ""))
        return queryTokens.intersection(candidateTokens).count
    }

    private static func tokenize(_ value: String) -> Set<String> {
        SearchTokenization.tokenize(value)
    }

    private static func inferredKind(
        resolvedURL: URL,
        title: String,
        fallback: ContentKind
    ) -> ContentKind {
        let normalizedPath = resolvedURL.path.lowercased()
        let normalizedURL = resolvedURL.absoluteString.lowercased()
        let normalizedTitle = title.lowercased()

        if isReferenceLike(path: normalizedPath, url: normalizedURL, title: normalizedTitle) {
            return .reference
        }

        if isGuideLike(path: normalizedPath) {
            return .guide
        }

        if isTutorialLike(path: normalizedPath, url: normalizedURL, title: normalizedTitle) {
            return .tutorial
        }

        if isSampleLike(path: normalizedPath, url: normalizedURL, title: normalizedTitle) {
            return .sample
        }

        return fallback
    }

    private static func isReferenceLike(path: String, url: String, title: String) -> Bool {
        path.contains("/reference/")
            || path.hasPrefix("/reference")
            || path.contains("/api/")
            || path.hasPrefix("/api")
            || title.contains("api reference")
            || title.hasSuffix(" api")
            || url.contains("reference") && title.contains("api")
    }

    private static func isGuideLike(path: String) -> Bool {
        path.contains("/guide/")
            || path.hasPrefix("/guide")
            || path.contains("/topic/")
            || path.hasPrefix("/topic")
    }

    private static func isTutorialLike(path: String, url: String, title: String) -> Bool {
        path.contains("/tutorial/")
            || path.hasPrefix("/tutorial")
            || path.contains("/tutorials/")
            || path.hasPrefix("/tutorials")
            || path.contains("/codelab")
            || url.contains("codelab")
            || title.contains("codelab")
    }

    private static func isSampleLike(path: String, url: String, title: String) -> Bool {
        path.contains("/sample/")
            || path.hasPrefix("/sample")
            || path.contains("/samples/")
            || path.hasPrefix("/samples")
            || path.contains("-sample")
            || url.contains("sample") && title.contains("sample")
    }
}

private struct ScoredResult {
    let order: Int
    let prefersPath: Bool
    let result: SearchResult
}
