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

import Testing
@testable import StandardsCollections

@Suite("Collections.Heap")
struct HeapTests {
    @Test("Min heap ordering")
    func minHeapOrdering() {
        var heap = Collections.Heap<Int>.min()
        heap.push(5)
        heap.push(3)
        heap.push(7)
        heap.push(1)

        #expect(heap.pop() == 1)
        #expect(heap.pop() == 3)
        #expect(heap.pop() == 5)
        #expect(heap.pop() == 7)
        #expect(heap.pop() == nil)
    }

    @Test("Max heap ordering")
    func maxHeapOrdering() {
        var heap = Collections.Heap<Int>.max()
        heap.push(5)
        heap.push(3)
        heap.push(7)
        heap.push(1)

        #expect(heap.pop() == 7)
        #expect(heap.pop() == 5)
        #expect(heap.pop() == 3)
        #expect(heap.pop() == 1)
        #expect(heap.pop() == nil)
    }

    @Test("Peek does not remove")
    func peekDoesNotRemove() {
        var heap = Collections.Heap<Int>.min()
        heap.push(3)
        heap.push(1)
        heap.push(2)

        #expect(heap.peek() == 1)
        #expect(heap.peek() == 1)
        #expect(heap.count == 3)
    }

    @Test("Empty heap")
    func emptyHeap() {
        var heap = Collections.Heap<Int>.min()
        #expect(heap.isEmpty)
        #expect(heap.count == 0)
        #expect(heap.peek() == nil)
        #expect(heap.pop() == nil)
    }

    @Test("Single element")
    func singleElement() {
        var heap = Collections.Heap<Int>.min()
        heap.push(42)
        #expect(!heap.isEmpty)
        #expect(heap.count == 1)
        #expect(heap.peek() == 42)
        #expect(heap.pop() == 42)
        #expect(heap.isEmpty)
    }

    @Test("Remove all")
    func removeAll() {
        var heap = Collections.Heap<Int>.min()
        heap.push(1)
        heap.push(2)
        heap.push(3)
        #expect(heap.count == 3)

        heap.removeAll()
        #expect(heap.isEmpty)
        #expect(heap.count == 0)
    }

    @Test("Duplicate elements")
    func duplicateElements() {
        var heap = Collections.Heap<Int>.min()
        heap.push(5)
        heap.push(5)
        heap.push(5)

        #expect(heap.pop() == 5)
        #expect(heap.pop() == 5)
        #expect(heap.pop() == 5)
        #expect(heap.pop() == nil)
    }
}
