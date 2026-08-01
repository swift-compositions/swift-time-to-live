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

import Time_To_Live

extension Store.InMemory {
    /// A stored value paired with the policy that governs its expiry.
    internal struct Entry: Sendable {
        let value: Value
        let ttl: TTL<Instant>
    }
}
