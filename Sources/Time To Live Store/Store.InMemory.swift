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

import Cache_Primitives
public import Time_To_Live

extension Store {
    /// An in-process, capacity-bounded key–value store whose entries expire
    /// under a per-entry ``TTL`` policy.
    ///
    /// `Store.InMemory` is *typed*: values are stored and returned as `Value`,
    /// with no `Any`-erasure. It is clock-agnostic — every expiry-sensitive
    /// operation takes the current `Instant` explicitly, mirroring
    /// ``TTL/isExpired(at:)``. `Instant` is any `InstantProtocol` value: the
    /// ecosystem's own `Instant` (swift-time-primitives) for absolute UTC time,
    /// or the injected clock's `Clock.Any.Instant` via the
    /// `Time To Live Dependencies` conveniences (`@Dependency(\.clock)`).
    ///
    /// ## Capacity and eviction
    ///
    /// The store holds at most `capacity` entries. Inserting a new key while
    /// the store is full evicts the oldest entry (insertion order); replacing an
    /// existing key's value evicts nothing. Expired entries are removed lazily
    /// on access via ``value(forKey:at:)`` and in bulk via ``prune(at:)``; until
    /// swept they still occupy capacity and are reported by ``count``.
    ///
    /// ## Thread safety
    ///
    /// The type is `Sendable` and internally synchronized (via the backing
    /// ``Cache/Bounded``); a `let` binding is safe to use from any isolation.
    ///
    /// ```swift
    /// import Time_Primitive   // ecosystem UTC `Instant`
    ///
    /// let store = Store.InMemory<String, Int, Instant>()
    /// let now = try Instant(secondsSinceUnixEpoch: 1_700_000_000)
    /// store.insert(42, forKey: "answer", ttl: TTL(.seconds(60), from: now))
    /// store.value(forKey: "answer", at: now)                              // 42
    /// store.value(forKey: "answer", at: now.advanced(by: .seconds(90)))   // nil (expired)
    /// ```
    public struct InMemory<
        Key: Hashable & Sendable,
        Value: Sendable,
        Instant: Swift.InstantProtocol
    >: Sendable {
        private let cache: Cache<Key, Entry>.Bounded

        /// Creates an empty store.
        ///
        /// - Parameter capacity: The maximum number of entries retained. When a
        ///   new key is inserted at capacity, the oldest entry is evicted. Must
        ///   be positive.
        public init(capacity: Int = 1000) {
            self.cache = Cache<Key, Entry>.Bounded(capacity: capacity)
        }
    }
}

// MARK: - Insertion

extension Store.InMemory {
    /// Inserts or replaces the value for a key under the given expiry policy.
    ///
    /// If `key` is already present, its value and policy are replaced in place
    /// (no eviction). If `key` is new and the store is at capacity, the oldest
    /// entry is evicted to make room.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The key to store it under.
    ///   - ttl: The expiry policy; a policy with no expiration never expires.
    public func insert(_ value: Value, forKey key: Key, ttl: TTL<Instant>) {
        cache.insert(Entry(value: value, ttl: ttl), forKey: key)
    }
}

// MARK: - Lookup

extension Store.InMemory {
    /// Returns the value for a key if it is present and not expired at `instant`.
    ///
    /// A value found to be expired at `instant` is removed as a side effect and
    /// `nil` is returned, so a stale entry never survives a lookup that observes
    /// its expiry.
    ///
    /// - Parameters:
    ///   - key: The key to look up.
    ///   - instant: The instant treated as "now" for the expiry check.
    /// - Returns: The live value, or `nil` if absent or expired.
    public func value(forKey key: Key, at instant: Instant) -> Value? {
        guard let entry = cache.getValue(forKey: key) else { return nil }
        guard !entry.ttl.isExpired(at: instant) else {
            cache.removeValue(forKey: key)
            return nil
        }
        return entry.value
    }
}

// MARK: - Removal

extension Store.InMemory {
    /// Removes the value for a key, whether or not it has expired.
    ///
    /// - Parameter key: The key to remove.
    /// - Returns: The removed value, or `nil` if the key was not present.
    @discardableResult
    public func removeValue(forKey key: Key) -> Value? {
        cache.removeValue(forKey: key)?.value
    }

    /// Removes every entry expired at `instant`, retaining the rest in order.
    ///
    /// - Parameter instant: The instant treated as "now" for the expiry check.
    public func prune(at instant: Instant) {
        cache.filter { _, entry in !entry.ttl.isExpired(at: instant) }
    }

    /// Removes all entries.
    public func removeAll() {
        cache.removeAll()
    }
}

// MARK: - Introspection

extension Store.InMemory {
    /// The number of stored entries, including any expired-but-unpruned entries.
    public var count: Int {
        cache.count
    }

    /// Whether the store holds no entries.
    public var isEmpty: Bool {
        cache.isEmpty
    }
}
