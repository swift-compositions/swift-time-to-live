import Time_To_Live

extension Store.InMemory {

    internal struct Entry: Sendable {
        let value: Value
        let ttl: TTL<Instant>
    }
}
