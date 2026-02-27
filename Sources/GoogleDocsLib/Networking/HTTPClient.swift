import Foundation

public protocol HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct URLSessionTransport: HTTPTransport {
    let session: URLSession

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

public struct HTTPResponse: Sendable {
    public let data: Data
    public let statusCode: Int
    public let url: URL

    public init(data: Data, statusCode: Int, url: URL) {
        self.data = data
        self.statusCode = statusCode
        self.url = url
    }
}

public struct HTTPClient {
    private let transport: any HTTPTransport
    private let retryPolicy: RetryPolicy

    public init(session: URLSession = .shared, retryPolicy: RetryPolicy = .init()) {
        transport = URLSessionTransport(session: session)
        self.retryPolicy = retryPolicy
    }

    init(transport: any HTTPTransport, retryPolicy: RetryPolicy = .init()) {
        self.transport = transport
        self.retryPolicy = retryPolicy
    }

    public func get(url: URL) async throws -> HTTPResponse {
        var currentAttempt = 0
        var lastError: Error?

        while currentAttempt < retryPolicy.maxAttempts {
            currentAttempt += 1

            do {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"

                let (data, response) = try await transport.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw CLIError.invalidResponse
                }

                if (200 ... 299).contains(httpResponse.statusCode) {
                    return HTTPResponse(data: data, statusCode: httpResponse.statusCode, url: url)
                }

                let body = String(decoding: data, as: UTF8.self)
                let statusError = CLIError.httpStatus(code: httpResponse.statusCode, body: body)

                if shouldRetryStatus(httpResponse.statusCode), currentAttempt < retryPolicy.maxAttempts {
                    try await Task.sleep(nanoseconds: retryPolicy.delay(for: currentAttempt + 1))
                    continue
                }

                throw statusError
            } catch {
                lastError = error
                if shouldRetryError(error), currentAttempt < retryPolicy.maxAttempts {
                    try await Task.sleep(nanoseconds: retryPolicy.delay(for: currentAttempt + 1))
                    continue
                }
                throw mapError(error)
            }
        }

        throw mapError(lastError ?? CLIError.network("Unknown error"))
    }

    private func shouldRetryStatus(_ statusCode: Int) -> Bool {
        statusCode == 429 || (500 ... 599).contains(statusCode)
    }

    private func shouldRetryError(_ error: Error) -> Bool {
        if let cliError = error as? CLIError {
            if case let .httpStatus(code, _) = cliError {
                return shouldRetryStatus(code)
            }
            return false
        }
        if let urlError = error as? URLError {
            return urlError.code != .userAuthenticationRequired
        }
        return false
    }

    private func mapError(_ error: Error) -> CLIError {
        if let cliError = error as? CLIError {
            return cliError
        }
        return CLIError.network(error.localizedDescription)
    }
}
