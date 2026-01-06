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

// MARK: - Keys Accessor

extension Collections.Dictionary.Ordered {
    /// Nested accessor for key operations.
    ///
    /// ```swift
    /// if let idx = dict.keys.index("apple") { ... }
    /// let allKeys = dict.keys.all
    /// ```
    @inlinable
    public var keys: Keys {
        Keys(dict: self)
    }
}

// MARK: - Keys Type

extension Collections.Dictionary.Ordered {
    /// Namespace for key operations.
    public struct Keys {
        @usableFromInline
        let dict: Collections.Dictionary.Ordered<Key, Value>

        @usableFromInline
        init(dict: Collections.Dictionary.Ordered<Key, Value>) {
            self.dict = dict
        }
    }
}

// MARK: - Keys Operations

extension Collections.Dictionary.Ordered.Keys {
    /// Returns the index of the given key, or `nil` if not present.
    ///
    /// - Parameter key: The key to find.
    /// - Returns: The index of the key.
    /// - Complexity: O(1) average.
    @inlinable
    public func index(_ key: Key) -> Int? {
        dict._keys.index(key)
    }

    /// All keys in order.
    @inlinable
    public var all: Collections.Set.Ordered<Key> {
        dict._keys
    }

    /// The key at the given index.
    ///
    /// - Parameter index: The index.
    /// - Precondition: The index must be in bounds.
    @inlinable
    public subscript(_ index: Int) -> Key {
        dict._keys[index]
    }
}

// MARK: - Sequence Conformance

extension Collections.Dictionary.Ordered.Keys: Sequence {
    public struct Iterator: IteratorProtocol {
        @usableFromInline
        var base: Collections.Set.Ordered<Key>.Iterator

        @usableFromInline
        init(_ keys: Collections.Set.Ordered<Key>) {
            self.base = keys.makeIterator()
        }

        @inlinable
        public mutating func next() -> Key? {
            base.next()
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(dict._keys)
    }
}

extension Collections.Dictionary.Ordered.Keys.Iterator: Sendable where Key: Sendable {}
