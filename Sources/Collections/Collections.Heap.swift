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

extension Collections {
    /// Binary heap with configurable ordering.
    ///
    /// A priority queue backed by a binary heap. O(log N) push/pop, O(1) peek.
    ///
    /// ## Thread Safety
    /// Not thread-safe for concurrent mutation. Synchronize externally.
    ///
    /// ## Usage
    /// ```swift
    /// var minHeap = Collections.Heap<Int>.min()
    /// minHeap.push(5)
    /// minHeap.push(3)
    /// minHeap.pop() // -> 3
    ///
    /// var maxHeap = Collections.Heap<Int>.max()
    /// ```
    public struct Heap<Element: Comparable> {
        /// Heap ordering strategy.
        public enum Order: Sendable {
            /// Smallest element has highest priority.
            case min
            /// Largest element has highest priority.
            case max
        }

        @usableFromInline
        var storage: [Element] = []

        /// The ordering of this heap.
        public let order: Order

        // MARK: - Initialization

        /// Creates a heap with the specified ordering.
        ///
        /// - Parameter order: The ordering strategy (default: `.min`).
        @inlinable
        public init(order: Order = .min) {
            self.order = order
        }

        /// Creates a min-heap (smallest first).
        @inlinable
        public static func min() -> Self {
            Self(order: .min)
        }

        /// Creates a max-heap (largest first).
        @inlinable
        public static func max() -> Self {
            Self(order: .max)
        }

        // MARK: - Queries

        /// The number of elements in the heap.
        @inlinable
        public var count: Int { storage.count }

        /// Whether the heap is empty.
        @inlinable
        public var isEmpty: Bool { storage.isEmpty }

        /// Returns the top element without removing it.
        ///
        /// - Returns: The highest-priority element, or `nil` if empty.
        /// - Complexity: O(1)
        @inlinable
        public func peek() -> Element? {
            storage.first
        }

        // MARK: - Mutations

        /// Adds an element to the heap.
        ///
        /// - Parameter element: The element to add.
        /// - Complexity: O(log N)
        @inlinable
        public mutating func push(_ element: Element) {
            storage.append(element)
            siftUp(from: storage.count - 1)
        }

        /// Removes and returns the highest-priority element.
        ///
        /// - Returns: The top element, or `nil` if empty.
        /// - Complexity: O(log N)
        @discardableResult
        @inlinable
        public mutating func pop() -> Element? {
            guard !storage.isEmpty else { return nil }

            if storage.count == 1 {
                return storage.removeLast()
            }

            let result = storage[0]
            storage[0] = storage.removeLast()
            siftDown(from: 0)
            return result
        }

        /// Removes all elements from the heap.
        ///
        /// - Parameter keepingCapacity: Whether to keep the underlying storage capacity.
        @inlinable
        public mutating func removeAll(keepingCapacity: Bool = false) {
            storage.removeAll(keepingCapacity: keepingCapacity)
        }

        // MARK: - Heap Operations

        /// Returns true if `a` has higher priority than `b`.
        @inlinable
        func hasHigherPriority(_ a: Element, than b: Element) -> Bool {
            switch order {
            case .min: return a < b
            case .max: return a > b
            }
        }

        /// Restores heap property by moving an element up.
        @inlinable
        mutating func siftUp(from index: Int) {
            var child = index
            var parent = parentIndex(of: child)

            while child > 0 && hasHigherPriority(storage[child], than: storage[parent]) {
                storage.swapAt(child, parent)
                child = parent
                parent = parentIndex(of: child)
            }
        }

        /// Restores heap property by moving an element down.
        @inlinable
        mutating func siftDown(from index: Int) {
            var parent = index

            while true {
                let left = leftChildIndex(of: parent)
                let right = rightChildIndex(of: parent)
                var candidate = parent

                if left < storage.count && hasHigherPriority(storage[left], than: storage[candidate]) {
                    candidate = left
                }
                if right < storage.count && hasHigherPriority(storage[right], than: storage[candidate]) {
                    candidate = right
                }

                if candidate == parent {
                    break
                }

                storage.swapAt(parent, candidate)
                parent = candidate
            }
        }

        // MARK: - Index Calculations

        @inlinable
        func parentIndex(of index: Int) -> Int {
            (index - 1) / 2
        }

        @inlinable
        func leftChildIndex(of index: Int) -> Int {
            2 * index + 1
        }

        @inlinable
        func rightChildIndex(of index: Int) -> Int {
            2 * index + 2
        }
    }
}

// MARK: - Conditional Conformances

extension Collections.Heap: Sendable where Element: Sendable {}
