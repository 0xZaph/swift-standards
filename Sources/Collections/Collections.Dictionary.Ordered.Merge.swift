// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-standards open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-standards project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - Merge Accessor

extension Collections.Dictionary.Ordered {
    /// Nested accessor for merge operations.
    ///
    /// ```swift
    /// dict.merge.keep.first(pairs)
    /// dict.merge.keep.last(pairs)
    /// ```
    @inlinable
    public var merge: Merge {
        get { Merge(dict: self) }
        _modify {
            var proxy = Merge(dict: self)
            defer { self = proxy.dict }
            yield &proxy
        }
    }
}

// MARK: - Merge Type

extension Collections.Dictionary.Ordered {
    /// Namespace for merge operations.
    public struct Merge {
        @usableFromInline
        var dict: Collections.Dictionary.Ordered<Key, Value>

        @usableFromInline
        init(dict: Collections.Dictionary.Ordered<Key, Value>) {
            self.dict = dict
        }
    }
}

// MARK: - Merge Keep Accessor

extension Collections.Dictionary.Ordered.Merge {
    /// Nested accessor for keep-policy merge operations.
    @inlinable
    public var keep: Keep {
        get { Keep(dict: dict) }
        _modify {
            var proxy = Keep(dict: dict)
            defer { dict = proxy.dict }
            yield &proxy
        }
    }
}
