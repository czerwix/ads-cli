import Foundation

public enum JSONRenderer {
    public static func renderSearchResults(_ results: [SearchResult]) throws -> String {
        try encode(results)
    }

    public static func renderDocument(_ page: DocumentPage) throws -> String {
        try encode(page)
    }

    public static func renderFrameworks(_ frameworks: [FrameworkEntry]) throws -> String {
        try encode(frameworks)
    }

    private static func encode<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(value)
        return String(decoding: data, as: UTF8.self)
    }
}
