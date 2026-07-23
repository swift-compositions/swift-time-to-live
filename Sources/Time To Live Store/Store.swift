// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-time-to-live open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-time-to-live project authors
// Licensed under Apache License 2.0
//
// See LICENSE.md for license information
//
// ===----------------------------------------------------------------------===//

/// Namespace for stores that expire values under a ``TTL`` policy.
///
/// `Store` is the family root for the package's TTL-aware storage variants.
/// Its first member is ``Store/InMemory``, an in-process, capacity-bounded
/// key-value store. Further members (durable, distributed) would nest here as
/// siblings; each is a *variant* of the store role rather than a distinct
/// domain, so they share this namespace per the `Nest.Name` pattern.
public enum Store {}
