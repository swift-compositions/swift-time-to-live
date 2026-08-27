# swift-time-to-live

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-compositions/swift-time-to-live/workflows/CI/badge.svg)](https://github.com/swift-compositions/swift-time-to-live/actions/workflows/ci.yml)

A clock-agnostic time-to-live policy and a typed, capacity-bounded in-memory store whose entries expire under it.

---

## Installation

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-compositions/swift-time-to-live.git",
        branch: "main"
    )
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Time To Live", package: "swift-time-to-live"),
        .product(name: "Time To Live Store", package: "swift-time-to-live"),
    ]
)
```

`Time To Live` carries the expiry policy alone; `Time To Live Store` adds the
in-memory store and re-exports the policy, so a consumer that needs the store
can depend on that product on its own.

The package publishes no tags yet, so the dependency is pinned to `main`.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public release.*
<!-- END: discussion -->

---

## License

Apache 2.0. See [LICENSE](LICENSE.md).
