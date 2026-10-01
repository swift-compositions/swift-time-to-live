import Testing
import Time
import Time_To_Live
import Time_To_Live_Store

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
        for key in 0..<5 {
            store.insert(key, forKey: key, ttl: TTL(from: Self.t0))
        }

        #expect(store.count == 2)
    }

    @Test
    func `pruning an empty store is a no-op`() {
        let store = Store.InMemory<String, Int, Time.Instant>()
        store.prune(at: Self.t0)

        #expect(store.isEmpty)
    }
}
