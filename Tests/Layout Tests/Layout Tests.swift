// Layout Tests.swift

import Testing

@testable import Layout

@Suite
struct `Layout Tests` {
    @Test
    func `Layout is a namespace`() {
        // Layout is a namespace type, this test just verifies it exists
        let _: Layout<Double, TestSpace>.Type = Layout<Double, TestSpace>.self
    }

    @Test
    func `Layout provides type aliases`() {
        // Verify the type aliases exist and resolve to correct types
        let _: TestLayout.Width.Type = TestLayout.Width.self
        let _: TestLayout.Height.Type = TestLayout.Height.self
        let _: TestLayout.Spacing.Type = TestLayout.Spacing.self
        let _: TestLayout.Point.Type = TestLayout.Point.self
        let _: TestLayout.Size.Type = TestLayout.Size.self
    }
}
