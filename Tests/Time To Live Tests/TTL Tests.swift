import Testing
import Time_Primitive

@testable import Time_To_Live

@Suite
struct `TTL Tests` {
    @Suite
    struct Unit {
        @Test
        func `missing duration never expires`() throws {
            let start = try Instant(secondsSinceUnixEpoch: 1_000_000)
            let policy = TTL<Instant>(from: start)

            #expect(policy.expiration == nil)
            #expect(!policy.isExpired(at: start))
        }
    }

    @Suite
    struct `Edge Case` {
        @Test
        func `negative duration is already expired`() throws {
            let start = try Instant(secondsSinceUnixEpoch: 1_000_000)
            let policy = TTL<Instant>(.seconds(-1), from: start)

            #expect(policy.isExpired(at: start))
        }
    }

    @Suite
    struct Integration {
        @Test
        func `duration creates an expiry deadline`() throws {
            let start = try Instant(secondsSinceUnixEpoch: 1_000_000)
            let policy = TTL<Instant>(.seconds(1), from: start)

            #expect(policy.expiration == start.advanced(by: .seconds(1)))
            #expect(!policy.isExpired(at: start))
            #expect(policy.isExpired(at: start.advanced(by: .seconds(1))))
        }
    }
}
