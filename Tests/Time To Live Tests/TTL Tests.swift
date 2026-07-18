import Testing

@testable import Time_To_Live

@Suite
struct `TTL Tests` {
    @Suite
    struct Unit {
        @Test
        func `missing duration never expires`() {
            let clock = ContinuousClock()
            let policy = TTL<ContinuousClock.Instant>(from: clock.now)

            #expect(policy.expiration == nil)
            #expect(!policy.isExpired(at: clock.now))
        }
    }

    @Suite
    struct `Edge Case` {
        @Test
        func `negative duration is already expired`() {
            let clock = ContinuousClock()
            let start = clock.now
            let policy = TTL<ContinuousClock.Instant>(.seconds(-1), from: start)

            #expect(policy.isExpired(at: start))
        }
    }

    @Suite
    struct Integration {
        @Test
        func `duration creates an expiry deadline`() {
            let clock = ContinuousClock()
            let start = clock.now
            let policy = TTL<ContinuousClock.Instant>(.seconds(1), from: start)

            #expect(policy.expiration == start.advanced(by: .seconds(1)))
            #expect(!policy.isExpired(at: start))
            #expect(policy.isExpired(at: start.advanced(by: .seconds(1))))
        }
    }
}
