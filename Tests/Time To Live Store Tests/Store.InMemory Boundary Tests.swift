import Testing
import Time
import Time_To_Live
import Time_To_Live_Store

enum `Store.InMemory Boundary Tests` {}

extension `Store.InMemory Boundary Tests` {
    @Suite
    struct `Store InMemory boundaries` {
        private static let t0 = Time.Instant(secondsSinceUnixEpoch: 1_000_000)

        @Test
        func `a value is gone at exactly its expiration`() {
            let store = Store.InMemory<String, Int, Time.Instant>()
            store.insert(1, forKey: "a", ttl: TTL(.seconds(10), from: Self.t0))

            #expect(store.value(forKey: "a", at: Self.t0.advanced(by: .seconds(10))) == nil)
            #expect(store.isEmpty)
        }

        @Test
        func `re-inserting a key replaces its value and expiration`() {
            let store = Store.InMemory<String, Int, Time.Instant>()
            store.insert(1, forKey: "a", ttl: TTL(.seconds(10), from: Self.t0))
            store.insert(2, forKey: "a", ttl: TTL(.seconds(100), from: Self.t0))

            #expect(store.count == 1)
            #expect(store.value(forKey: "a", at: Self.t0.advanced(by: .seconds(50))) == 2)
        }

        @Test
        func `the store never holds more entries than its capacity`() {
            let store = Store.InMemory<Int, Int, Time.Instant>(capacity: 2)
            (0..<5).forEach { key in
                store.insert(key, forKey: key, ttl: TTL(from: Self.t0))
            }

            #expect(store.count == 2)
        }

        @Test
        func `inserting into a full store evicts expired entries before a live one`() {
            let store = Store.InMemory<String, Int, Time.Instant>(capacity: 2)
            store.insert(1, forKey: "live", ttl: TTL(.seconds(100), from: Self.t0))
            store.insert(2, forKey: "expired", ttl: TTL(.seconds(10), from: Self.t0))

            let now = Self.t0.advanced(by: .seconds(50))
            store.insert(3, forKey: "new", ttl: TTL(.seconds(100), from: now), at: now)

            #expect(store.count == 2)
            #expect(store.value(forKey: "live", at: now) == 1)
            #expect(store.value(forKey: "new", at: now) == 3)
        }

        @Test
        func `inserting into a full store with only live entries evicts the oldest`() {
            let store = Store.InMemory<String, Int, Time.Instant>(capacity: 2)
            store.insert(1, forKey: "first", ttl: TTL(.seconds(100), from: Self.t0), at: Self.t0)
            store.insert(2, forKey: "second", ttl: TTL(.seconds(100), from: Self.t0), at: Self.t0)
            store.insert(3, forKey: "third", ttl: TTL(.seconds(100), from: Self.t0), at: Self.t0)

            #expect(store.count == 2)
            #expect(store.value(forKey: "first", at: Self.t0) == nil)
            #expect(store.value(forKey: "third", at: Self.t0) == 3)
        }

        @Test
        func `pruning an empty store is a no-op`() {
            let store = Store.InMemory<String, Int, Time.Instant>()
            store.prune(at: Self.t0)

            #expect(store.isEmpty)
        }
    }
}
