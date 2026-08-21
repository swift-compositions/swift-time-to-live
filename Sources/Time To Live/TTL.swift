public struct TTL<Instant: Swift.InstantProtocol>: Sendable where Instant: Sendable {

    public let expiration: Instant?
}

extension TTL {

    @inlinable
    public init(_ duration: Instant.Duration? = nil, from start: Instant) {
        self.expiration = duration.map { start.advanced(by: $0) }
    }

    @inlinable
    public func isExpired(at instant: Instant) -> Bool {
        guard let expiration else { return false }
        return instant >= expiration
    }
}
