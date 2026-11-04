# swift-time-to-live

Use this package when values should stop being served after a set time, and you want to decide expiry against an instant you pass in, from any clock. Start from `TTL<Instant>` for the expiry rule alone, and `Store.InMemory<Key, Value, Instant>` for a bounded in-memory store whose entries expire under it. The `Time To Live Dependencies` product adds overloads that take the current instant from the injected `clock` dependency instead. If you need to compute an expensive value once per key with no expiry, use `Cache<Key, Value>` from swift-cache.

## Laws

- A `TTL<Instant>` expires at its expiration instant, not after it. With no duration it never expires. A zero or negative duration is already expired at its start.
- `Store.InMemory<Key, Value, Instant>` never removes an entry because time passes. An expired entry stays stored, and counts toward `count` and the capacity, until a lookup at or after its expiration removes it, or `Store.InMemory.prune(at:)` does.
- The store holds at most `capacity` entries, 1000 by default. Inserting a new key into a full store evicts the entry inserted earliest, whether or not it has expired. Replacing an existing key keeps its place and evicts nothing, and reading a key does not change the order.
- Inserting an existing key replaces both its value and its expiration.
- `Store.InMemory<Key, Value, Instant>` is a struct, but its copies share one set of entries.
- The dependency overloads read the `clock` dependency each time they are called. They exist only for stores and policies whose instant is `Clock.Any<Time.Duration>.Instant`. Without `expiresIn`, an entry never expires.
