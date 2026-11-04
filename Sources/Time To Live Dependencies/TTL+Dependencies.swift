public import Clock_Concurrency
import Dependencies
public import Time
public import Time_To_Live

extension TTL where Instant == Clock.`Any`<Time::Duration>.Instant {

    public func isExpired() -> Bool {
        @Dependency(\.clock) var clock
        return self.isExpired(at: clock.now)
    }
}
