import Clock_Concurrency
import Dependencies
import Dependencies_Test_Support
import Testing
import Time
import Time_To_Live_Store

@testable import Time_To_Live_Dependencies

enum `Store.InMemory+Dependencies Tests` {}

extension `Store.InMemory+Dependencies Tests` {
    @Suite
    struct `Store InMemory Dependencies Tests` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension `Store.InMemory+Dependencies Tests`.`Store InMemory Dependencies Tests`.Unit {
    @Test
    func `insert expiresIn and value resolve the injected clock`() async {
        let test = Clock.Test()
        let clock = Clock.`Any`(test)
        let store = Store.InMemory<String, Int, Clock.`Any`<Time::Duration>.Instant>()

        await withDependencies {
            $0.clock = clock
        } operation: {
            store.insert(1, forKey: "a", expiresIn: .seconds(10))
            #expect(store.value(forKey: "a") == 1)

            await test.advance(by: .seconds(20))
            #expect(store.value(forKey: "a") == nil)
        }
    }

    @Test
    func `an absent duration never expires`() async {
        let test = Clock.Test()
        let clock = Clock.`Any`(test)
        let store = Store.InMemory<String, Int, Clock.`Any`<Time::Duration>.Instant>()

        await withDependencies {
            $0.clock = clock
        } operation: {
            store.insert(7, forKey: "eternal")

            await test.advance(by: .seconds(10_000))
            #expect(store.value(forKey: "eternal") == 7)
        }
    }

    @Test
    func `prune drops entries expired at the injected instant`() async {
        let test = Clock.Test()
        let clock = Clock.`Any`(test)
        let store = Store.InMemory<String, Int, Clock.`Any`<Time::Duration>.Instant>()

        await withDependencies {
            $0.clock = clock
        } operation: {
            store.insert(1, forKey: "short", expiresIn: .seconds(10))
            store.insert(2, forKey: "long", expiresIn: .seconds(100))

            await test.advance(by: .seconds(50))
            store.prune()

            #expect(store.count == 1)
            #expect(store.value(forKey: "long") == 2)
        }
    }
}
