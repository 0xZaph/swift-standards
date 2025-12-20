// Layout.Stack Tests.swift

import Testing

@testable import Geometry
@testable import Layout

// MARK: - Stack Tests

@Suite
struct `Layout.Stack Tests` {
    @Test
    func `Stack vertical convenience`() {
        let spacing: TestLayout.Spacing = 10.0
        let stack: TestLayout.Stack<[Int]> = .vertical(
            spacing: spacing,
            alignment: .leading,
            content: [1, 2, 3]
        )

        #expect(stack.axis == .secondary)
        #expect(stack.spacing == spacing)
        #expect(stack.alignment == .leading)
        #expect(stack.content == [1, 2, 3])
    }

    @Test
    func `Stack horizontal convenience`() {
        let spacing: TestLayout.Spacing = 8.0
        let stack: TestLayout.Stack<[Int]> = .horizontal(
            spacing: spacing,
            alignment: .center,
            content: [1, 2, 3]
        )

        #expect(stack.axis == .primary)
        #expect(stack.spacing == spacing)
        #expect(stack.alignment == .center)
    }

    @Test
    func `Stack default alignment`() {
        let spacing: TestLayout.Spacing = 10.0
        let stack: TestLayout.Stack<[Int]> = .vertical(
            spacing: spacing,
            content: [1, 2, 3]
        )

        #expect(stack.alignment == .center)
    }

    @Test
    func `Stack Equatable`() {
        let spacing10: TestLayout.Spacing = 10.0
        let spacing20: TestLayout.Spacing = 20.0

        let a: TestLayout.Stack<[Int]> = .vertical(spacing: spacing10, content: [1, 2])
        let b: TestLayout.Stack<[Int]> = .vertical(spacing: spacing10, content: [1, 2])
        let c: TestLayout.Stack<[Int]> = .vertical(spacing: spacing20, content: [1, 2])

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Stack map content`() throws {
        let spacing: TestLayout.Spacing = 10.0
        let stack: TestLayout.Stack<[Int]> = .vertical(
            spacing: spacing,
            content: [1, 2, 3]
        )

        let mapped: TestLayout.Stack<[String]> = try stack.map.content { $0.map { String($0) } }
        #expect(mapped.content == ["1", "2", "3"])
        #expect(mapped.spacing == spacing)
    }

    @Test
    func `Stack is Sendable`() {
        let spacing: TestLayout.Spacing = 10.0
        let stack: TestLayout.Stack<[Int]> = .vertical(spacing: spacing, content: [1, 2])
        let _: any Sendable = stack
    }

    @Test
    func `Stack is Hashable`() {
        let spacing: TestLayout.Spacing = 10.0
        let stack: TestLayout.Stack<[Int]> = .vertical(spacing: spacing, content: [1, 2])
        var set = Set<TestLayout.Stack<[Int]>>()
        set.insert(stack)
        #expect(set.count == 1)
    }
}
