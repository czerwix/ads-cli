import Foundation

enum SearchTokenization {
    static let minimumTokenLength = 3

    static func tokenize(_ value: String) -> Set<String> {
        let tokens = value.lowercased().split { character in
            !character.isLetter && !character.isNumber
        }

        return Set(tokens.compactMap { token in
            let normalizedToken = String(token)
            return normalizedToken.count >= minimumTokenLength ? normalizedToken : nil
        })
    }
}
