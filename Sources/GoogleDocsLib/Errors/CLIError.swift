import Foundation

public enum CLIError: Error, LocalizedError, Sendable {
    case invalidResponse
    case httpStatus(code: Int, body: String)
    case network(String)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Received an invalid HTTP response."
        case let .httpStatus(code, body):
            if body.isEmpty {
                return "Request failed with HTTP status \(code)."
            }
            return "Request failed with HTTP status \(code): \(body)"
        case let .network(message):
            return "Network error: \(message)"
        }
    }
}
