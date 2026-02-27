public struct RetryPolicy: Sendable {
    public let maxAttempts: Int
    public let baseDelayNanoseconds: UInt64

    public init(maxAttempts: Int = 3, baseDelayNanoseconds: UInt64 = 300_000_000) {
        self.maxAttempts = max(1, maxAttempts)
        self.baseDelayNanoseconds = baseDelayNanoseconds
    }

    func delay(for attempt: Int) -> UInt64 {
        guard attempt > 1 else { return 0 }
        return baseDelayNanoseconds * UInt64(1 << (attempt - 2))
    }
}
