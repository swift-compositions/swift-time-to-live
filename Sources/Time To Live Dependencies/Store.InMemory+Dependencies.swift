public import Clock_Concurrency
import Dependencies
public import Time
import Time_To_Live
public import Time_To_Live_Store

extension Store.InMemory where Instant == Clock.`Any`<Time::Duration>.Instant {

    public func insert(
        _ value: Value,
        forKey key: Key,
        expiresIn duration: Time::Duration? = nil
    ) {
        @Dependency(\.clock) var clock
        insert(value, forKey: key, ttl: TTL(duration, from: clock.now))
    }

    public func value(forKey key: Key) -> Value? {
        @Dependency(\.clock) var clock
        return value(forKey: key, at: clock.now)
    }

    public func prune() {
        @Dependency(\.clock) var clock
        prune(at: clock.now)
    }
}
