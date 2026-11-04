import Clock_Concurrency
import Dependencies
import Dependencies_Test_Support
import Testing
import Time
import Time_To_Live

@testable import Time_To_Live_Dependencies

@Suite
struct `TTL Dependencies Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `TTL Dependencies Tests`.Unit {
    @Test
    func `the injected clock supplies the current instant`() async {
        let test = Clock.Test()
        let clock = Clock.`Any`(test)
        let start = clock.now
        let policy = TTL<Clock.`Any`<Time::Duration>.Instant>(.seconds(5), from: start)

        await withDependencies {
            $0.clock = clock
        } operation: {
            #expect(!policy.isExpired())
            await test.advance(by: .seconds(5))
            #expect(policy.isExpired())
        }
    }
}

extension `TTL Dependencies Tests`.`Edge Case` {
    @Test
    func `an absent duration remains unexpired`() {
        let test = Clock.Test()
        let clock = Clock.`Any`(test)
        let policy = TTL<Clock.`Any`<Time::Duration>.Instant>(from: clock.now)

        withDependencies {
            $0.clock = clock
        } operation: {
            #expect(!policy.isExpired())
        }
    }
}
