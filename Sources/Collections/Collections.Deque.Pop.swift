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

// MARK: - Pop Accessor

extension Collections.Deque {
    /// Nested accessor for pop operations.
    ///
    /// ```swift
    /// var deque: Collections.Deque<Int> = [1, 2, 3]
    /// let back = try deque.pop.back()
    /// let front = try deque.pop.front()
    /// ```
    @inlinable
    public var pop: Pop {
        get { Pop(deque: self) }
        _modify {
            var proxy = Pop(deque: self)
            defer { self = proxy.deque }
            yield &proxy
        }
    }
}

// MARK: - Pop Type

extension Collections.Deque {
    /// Namespace for pop operations.
    public struct Pop {
        @usableFromInline
        var deque: Collections.Deque<Element>

        @usableFromInline
        init(deque: Collections.Deque<Element>) {
            self.deque = deque
        }
    }
}

// MARK: - Pop Operations

extension Collections.Deque.Pop {
    /// Pops an element from the back of the deque.
    ///
    /// - Returns: The removed element.
    /// - Throws: `Deque.Error.empty` if the deque is empty.
    /// - Complexity: O(1).
    @inlinable
    public mutating func back() throws(Collections.Deque<Element>.Error) -> Element {
        try deque._pop(from: Collections.Deque<Element>.End.back)
    }

    /// Pops an element from the front of the deque.
    ///
    /// - Returns: The removed element.
    /// - Throws: `Deque.Error.empty` if the deque is empty.
    /// - Complexity: O(1).
    @inlinable
    public mutating func front() throws(Collections.Deque<Element>.Error) -> Element {
        try deque._pop(from: Collections.Deque<Element>.End.front)
    }
}
