// Layout.Grid Tests.swift

import Testing

@testable import Geometry
@testable import Layout

// MARK: - Grid Tests

@Suite
struct `Layout.Grid Tests` {
    @Test
    func `Grid basic creation`() {
        let rowSpacing: TestLayout.Height = 10.0
        let columnSpacing: TestLayout.Width = 8.0

        let grid: TestLayout.Grid<[[Int]]> = .init(
            spacing: .init(row: rowSpacing, column: columnSpacing),
            alignment: .center,
            content: [[1, 2], [3, 4]]
        )

        #expect(grid.spacing.row == rowSpacing)
        #expect(grid.spacing.column == columnSpacing)
        #expect(grid.alignment == .center)
    }

    @Test
    func `Grid uniform convenience`() {
        let uniformSpacing: TestLayout.Spacing = 10.0

        let grid: TestLayout.Grid<[[Int]]> = .uniform(
            spacing: uniformSpacing,
            content: [[1, 2], [3, 4]]
        )

        #expect(grid.spacing.row == uniformSpacing.height)
        #expect(grid.spacing.column == uniformSpacing.width)
    }

    @Test
    func `Grid default alignment`() {
        let rowSpacing: TestLayout.Height = 10.0
        let columnSpacing: TestLayout.Width = 8.0

        let grid: TestLayout.Grid<[[Int]]> = .init(
            spacing: .init(row: rowSpacing, column: columnSpacing),
            content: [[1, 2], [3, 4]]
        )

        #expect(grid.alignment == .center)
    }

    @Test
    func `Grid Equatable`() {
        let spacing10: TestLayout.Spacing = 10.0
        let spacing20: TestLayout.Spacing = 20.0

        let a: TestLayout.Grid<[[Int]]> = .uniform(spacing: spacing10, content: [[1, 2]])
        let b: TestLayout.Grid<[[Int]]> = .uniform(spacing: spacing10, content: [[1, 2]])
        let c: TestLayout.Grid<[[Int]]> = .uniform(spacing: spacing20, content: [[1, 2]])

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Grid map content`() throws {
        let spacing: TestLayout.Spacing = 10.0
        let grid: TestLayout.Grid<[[Int]]> = .uniform(spacing: spacing, content: [[1, 2]])

        let mapped: TestLayout.Grid<[[String]]> = try grid.map.content { rows in
            rows.map { row in row.map { String($0) } }
        }
        #expect(mapped.content == [["1", "2"]])
        #expect(mapped.spacing.row == spacing.height)
        #expect(mapped.spacing.column == spacing.width)
    }

    @Test
    func `Grid is Sendable`() {
        let spacing: TestLayout.Spacing = 10.0
        let grid: TestLayout.Grid<[[Int]]> = .uniform(spacing: spacing, content: [[1, 2]])
        let _: any Sendable = grid
    }
}
