import Foundation
import Testing
@testable import GoogleDocsLib

struct HTTPClientTests {
    @Test
    func retriesOnServerErrorThenSucceeds() async throws {
        let transport = MockTransport(responses: [
            .init(statusCode: 500, body: Data("temporary".utf8)),
            .init(statusCode: 200, body: Data("ok".utf8))
        ])

        let client = HTTPClient(transport: transport, retryPolicy: .init(maxAttempts: 2, baseDelayNanoseconds: 1))
        let response = try await client.get(url: URL(string: "https://example.com")!)

        #expect(String(decoding: response.data, as: UTF8.self) == "ok")
        #expect(await transport.requestCount == 2)
    }

    @Test
    func doesNotRetryOnClientError() async {
        let transport = MockTransport(responses: [
            .init(statusCode: 404, body: Data("missing".utf8))
        ])

        let client = HTTPClient(transport: transport, retryPolicy: .init(maxAttempts: 3, baseDelayNanoseconds: 1))

        await #expect(throws: CLIError.self) {
            _ = try await client.get(url: URL(string: "https://example.com")!)
        }

        #expect(await transport.requestCount == 1)
    }
}

private struct MockResponse: Sendable {
    let statusCode: Int
    let body: Data
}

private actor MockTransport: HTTPTransport {
    private var responses: [MockResponse]
    private(set) var requestCount = 0

    init(responses: [MockResponse]) {
        self.responses = responses
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requestCount += 1
        guard !responses.isEmpty else {
            throw URLError(.badServerResponse)
        }

        let next = responses.removeFirst()
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: next.statusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        return (next.body, response)
    }
}
