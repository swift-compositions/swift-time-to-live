import Testing
import Time_To_Live
import Time_To_Live_Store

@Suite
struct `Store InMemory Tests` {

    @Suite
    struct Lookup {
        @Test
        func `returns a live value`() {
            let t0 = ContinuousClock().now
            let store = Time_To_Live_Store.Store.InMemory<String, Int, ContinuousClock.Instant>()

            store.insert(42, forKey: "answer", ttl: TTL(.seconds(60), from: t0))

            #expect(store.value(forKey: "answer", at: t0) == 42)
            #expect(store.value(forKey: "missing", at: t0) == nil)
        }

        @Test
        func `a policy with no expiration never expires`() {
            let t0 = ContinuousClock().now
            let store = Time_To_Live_Store.Store.InMemory<String, Int, ContinuousClock.Instant>()

            store.insert(7, forKey: "eternal", ttl: TTL(nil, from: t0))

            #expect(store.value(forKey: "eternal", at: t0) == 7)
            #expect(store.value(forKey: "eternal", at: t0.advanced(by: .seconds(10_000))) == 7)
        }
    }

    @Suite
    struct Expiry {
        @Test
        func `an expired value is absent and removed on lookup`() {
            let t0 = ContinuousClock().now
            let store = Time_To_Live_Store.Store.InMemory<String, Int, ContinuousClock.Instant>()

            store.insert(1, forKey: "a", ttl: TTL(.seconds(10), from: t0))
            #expect(store.count == 1)

            // Not yet expired.
            #expect(store.value(forKey: "a", at: t0.advanced(by: .seconds(5))) == 1)

            // Expired: absent, and lazily removed as a side effect.
            #expect(store.value(forKey: "a", at: t0.advanced(by: .seconds(20))) == nil)
            #expect(store.count == 0)
        }

        @Test
        func `prune removes only the expired entries`() {
            let t0 = ContinuousClock().now
            let store = Time_To_Live_Store.Store.InMemory<String, Int, ContinuousClock.Instant>()

            store.insert(1, forKey: "short", ttl: TTL(.seconds(10), from: t0))
            store.insert(2, forKey: "long", ttl: TTL(.seconds(100), from: t0))
            store.insert(3, forKey: "eternal", ttl: TTL(nil, from: t0))
            #expect(store.count == 3)

            store.prune(at: t0.advanced(by: .seconds(50)))

            #expect(store.count == 2)
            #expect(store.value(forKey: "short", at: t0.advanced(by: .seconds(50))) == nil)
            #expect(store.value(forKey: "long", at: t0.advanced(by: .seconds(50))) == 2)
            #expect(store.value(forKey: "eternal", at: t0.advanced(by: .seconds(50))) == 3)
        }
    }

    @Suite
    struct Removal {
        @Test
        func `removeValue returns and removes the entry`() {
            let t0 = ContinuousClock().now
            let store = Time_To_Live_Store.Store.InMemory<String, Int, ContinuousClock.Instant>()

            store.insert(9, forKey: "k", ttl: TTL(nil, from: t0))

            #expect(store.removeValue(forKey: "k") == 9)
            #expect(store.removeValue(forKey: "k") == nil)
            #expect(store.value(forKey: "k", at: t0) == nil)
        }

        @Test
        func `removeAll empties the store`() {
            let t0 = ContinuousClock().now
            let store = Time_To_Live_Store.Store.InMemory<String, Int, ContinuousClock.Instant>()

            store.insert(1, forKey: "a", ttl: TTL(nil, from: t0))
            store.insert(2, forKey: "b", ttl: TTL(nil, from: t0))
            #expect(!store.isEmpty)

            store.removeAll()
            #expect(store.isEmpty)
            #expect(store.count == 0)
        }
    }

    @Suite
    struct Capacity {
        @Test
        func `inserting a new key at capacity evicts the oldest`() {
            let t0 = ContinuousClock().now
            let store = Time_To_Live_Store.Store.InMemory<String, Int, ContinuousClock.Instant>(capacity: 2)

            store.insert(1, forKey: "a", ttl: TTL(nil, from: t0))
            store.insert(2, forKey: "b", ttl: TTL(nil, from: t0))
            store.insert(3, forKey: "c", ttl: TTL(nil, from: t0))  // evicts "a" (oldest)

            #expect(store.count == 2)
            #expect(store.value(forKey: "a", at: t0) == nil)
            #expect(store.value(forKey: "b", at: t0) == 2)
            #expect(store.value(forKey: "c", at: t0) == 3)
        }

        @Test
        func `replacing an existing key does not evict`() {
            let t0 = ContinuousClock().now
            let store = Time_To_Live_Store.Store.InMemory<String, Int, ContinuousClock.Instant>(capacity: 2)

            store.insert(1, forKey: "a", ttl: TTL(nil, from: t0))
            store.insert(2, forKey: "b", ttl: TTL(nil, from: t0))
            store.insert(20, forKey: "b", ttl: TTL(nil, from: t0))  // replace, not a new key

            #expect(store.count == 2)
            #expect(store.value(forKey: "a", at: t0) == 1)
            #expect(store.value(forKey: "b", at: t0) == 20)
        }
    }
}
