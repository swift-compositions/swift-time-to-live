// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-time-to-live open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-time-to-live project authors
// Licensed under Apache License 2.0
//
// See LICENSE.md for license information
//
// ===----------------------------------------------------------------------===//

/// A value's optional time-to-live policy, independent of storage or a clock engine.
public struct TTL<Instant: Swift.InstantProtocol>: Sendable where Instant: Sendable {
    /// The instant at which the value becomes unavailable, or `nil` for no expiry.
    public let expiration: Instant?
}

extension TTL {
    /// Creates a policy from a TTL measured from the supplied instant.
    @inlinable
    public init(_ duration: Instant.Duration? = nil, from start: Instant) {
        self.expiration = duration.map { start.advanced(by: $0) }
    }

    /// Whether the value is expired at the supplied instant.
    @inlinable
    public func isExpired(at instant: Instant) -> Bool {
        guard let expiration else { return false }
        return instant >= expiration
    }
}
