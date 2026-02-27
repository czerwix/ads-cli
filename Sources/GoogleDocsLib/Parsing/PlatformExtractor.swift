import Foundation

public enum PlatformExtractor {
    public static func extractMetadata(from html: String) -> [String: String] {
        var metadata: [String: String] = [:]

        if let api = extractFirst(from: html, pattern: #"API\s*level\s*(\d+)"#) {
            metadata["androidApiLevel"] = api
        }

        if let artifact = extractFirst(
            from: html,
            pattern: #"(androidx\.[a-z0-9_.-]+:[a-z0-9_.-]+(?::[a-z0-9_.-]+)?)"#
        ) {
            metadata["artifact"] = artifact
        }

        return metadata
    }

    private static func extractFirst(from html: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        guard let match = regex.firstMatch(in: html, options: [], range: range),
              match.numberOfRanges > 1,
              let extractedRange = Range(match.range(at: 1), in: html)
        else {
            return nil
        }

        return String(html[extractedRange])
    }
}
