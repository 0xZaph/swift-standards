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

// MARK: - Push Accessor

extension Collections.Deque {
    /// Nested accessor for push operations.
    ///
    /// ```swift
    /// var deque = Collections.Deque<Int>()
    /// deque.push.back(1)
    /// deque.push.front(0)
    /// ```
    @inlinable
    public var push: Push {
        get { Push(deque: self) }
        _modify {
            var proxy = Push(deque: self)
            defer { self = proxy.deque }
            yield &proxy
        }
    }
}

// MARK: - Push Type

extension Collections.Deque {
    /// Namespace for push operations.
    public struct Push {
        @usableFromInline
        var deque: Collections.Deque<Element>

        @usableFromInline
        init(deque: Collections.Deque<Element>) {
            self.deque = deque
        }
    }
}

// MARK: - Push Operations

extension Collections.Deque.Push {
    /// Pushes an element to the back of the deque.
    ///
    /// - Parameter element: The element to push.
    /// - Complexity: O(1) amortized.
    @inlinable
    public mutating func back(_ element: Element) {
        deque._push(element, to: Collections.Deque<Element>.End.back)
    }

    /// Pushes an element to the front of the deque.
    ///
    /// - Parameter element: The element to push.
    /// - Complexity: O(1) amortized.
    @inlinable
    public mutating func front(_ element: Element) {
        deque._push(element, to: Collections.Deque<Element>.End.front)
    }
}
