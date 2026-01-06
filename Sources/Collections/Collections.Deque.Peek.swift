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

// MARK: - Peek Accessor

extension Collections.Deque {
    /// Nested accessor for peek operations.
    ///
    /// ```swift
    /// let deque: Collections.Deque<Int> = [1, 2, 3]
    /// if let back = deque.peek.back { ... }
    /// if let front = deque.peek.front { ... }
    /// ```
    @inlinable
    public var peek: Peek {
        Peek(deque: self)
    }
}

// MARK: - Peek Type

extension Collections.Deque {
    /// Namespace for peek operations.
    public struct Peek {
        @usableFromInline
        let deque: Collections.Deque<Element>

        @usableFromInline
        init(deque: Collections.Deque<Element>) {
            self.deque = deque
        }
    }
}

// MARK: - Peek Operations

extension Collections.Deque.Peek {
    /// The element at the back of the deque, or `nil` if empty.
    ///
    /// - Complexity: O(1).
    @inlinable
    public var back: Element? {
        deque._peek(at: Collections.Deque<Element>.End.back)
    }

    /// The element at the front of the deque, or `nil` if empty.
    ///
    /// - Complexity: O(1).
    @inlinable
    public var front: Element? {
        deque._peek(at: Collections.Deque<Element>.End.front)
    }
}
