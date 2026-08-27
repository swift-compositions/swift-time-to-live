import Cache
public import Time_To_Live

extension Store {

    public struct InMemory<
        Key: Hashable & Sendable,
        Value: Sendable,
        Instant: Swift.InstantProtocol
    >: Sendable {
        private let cache: Cache<Key, Entry>.Bounded

        public init(capacity: Int = 1000) {
            self.cache = Cache<Key, Entry>.Bounded(capacity: capacity)
        }
    }
}

extension Store.InMemory {

    public func insert(_ value: Value, forKey key: Key, ttl: TTL<Instant>) {
        cache.insert(Entry(value: value, ttl: ttl), forKey: key)
    }
}

extension Store.InMemory {

    public func value(forKey key: Key, at instant: Instant) -> Value? {
        guard let entry = cache.getValue(forKey: key) else { return nil }
        guard !entry.ttl.isExpired(at: instant) else {
            cache.removeValue(forKey: key)
            return nil
        }
        return entry.value
    }
}

extension Store.InMemory {

    @discardableResult
    public func removeValue(forKey key: Key) -> Value? {
        cache.removeValue(forKey: key)?.value
    }

    public func prune(at instant: Instant) {
        cache.filter { _, entry in !entry.ttl.isExpired(at: instant) }
    }

    public func removeAll() {
        cache.removeAll()
    }
}

extension Store.InMemory {

    public var count: Int {
        cache.count
    }

    public var isEmpty: Bool {
        cache.isEmpty
    }
}
