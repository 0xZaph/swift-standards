// Layout.Flow Tests.swift

import Testing

@testable import Geometry
@testable import Layout

// MARK: - Flow Tests

@Suite
struct `Layout.Flow Tests` {
    @Test
    func `Flow basic creation`() {
        let itemSpacing: TestLayout.Width = 8.0
        let lineSpacing: TestLayout.Height = 12.0

        let flow: TestLayout.Flow<[String]> = .init(
            spacing: .init(item: itemSpacing, line: lineSpacing),
            alignment: .leading,
            line: .top,
            content: ["a", "b", "c"]
        )

        #expect(flow.spacing.item == itemSpacing)
        #expect(flow.spacing.line == lineSpacing)
        #expect(flow.alignment == Horizontal.Alignment.leading)
        #expect(flow.line.alignment == Vertical.Alignment.top)
    }

    @Test
    func `Flow default alignments`() {
        let itemSpacing: TestLayout.Width = 8.0
        let lineSpacing: TestLayout.Height = 12.0

        let flow: TestLayout.Flow<[String]> = .init(
            spacing: .init(item: itemSpacing, line: lineSpacing),
            content: ["a", "b", "c"]
        )

        #expect(flow.alignment == Horizontal.Alignment.leading)
        #expect(flow.line.alignment == Vertical.Alignment.top)
    }

    @Test
    func `Flow uniform convenience`() {
        let uniformSpacing: TestLayout.Spacing = 10.0

        let flow: TestLayout.Flow<[String]> = .uniform(
            spacing: uniformSpacing,
            content: ["a", "b", "c"]
        )

        #expect(flow.spacing.item == uniformSpacing.width)
        #expect(flow.spacing.line == uniformSpacing.height)
    }

    @Test
    func `Flow Equatable`() {
        let spacing10: TestLayout.Spacing = 10.0
        let spacing20: TestLayout.Spacing = 20.0

        let a: TestLayout.Flow<[String]> = .uniform(spacing: spacing10, content: ["a"])
        let b: TestLayout.Flow<[String]> = .uniform(spacing: spacing10, content: ["a"])
        let c: TestLayout.Flow<[String]> = .uniform(spacing: spacing20, content: ["a"])

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Flow map content`() throws {
        let spacing: TestLayout.Spacing = 10.0
        let flow: TestLayout.Flow<[Int]> = .uniform(spacing: spacing, content: [1, 2, 3])

        let mapped: TestLayout.Flow<[String]> = try flow.map.content { $0.map { String($0) } }
        #expect(mapped.content == ["1", "2", "3"])
        #expect(mapped.spacing.item == spacing.width)
        #expect(mapped.spacing.line == spacing.height)
    }

    @Test
    func `Flow is Sendable`() {
        let spacing: TestLayout.Spacing = 10.0
        let flow: TestLayout.Flow<[String]> = .uniform(spacing: spacing, content: ["a"])
        let _: any Sendable = flow
    }

    @Test
    func `Flow is Hashable`() {
        let spacing: TestLayout.Spacing = 10.0
        let flow: TestLayout.Flow<[String]> = .uniform(spacing: spacing, content: ["a"])
        var set = Set<TestLayout.Flow<[String]>>()
        set.insert(flow)
        #expect(set.count == 1)
    }
}

@Suite
struct `Layout.Flow.Line Tests` {
    @Test
    func `Flow.Line top`() {
        let line: TestLayout.Flow<[String]>.Line = .top
        #expect(line.alignment == Vertical.Alignment.top)
    }

    @Test
    func `Flow.Line center`() {
        let line: TestLayout.Flow<[String]>.Line = .center
        #expect(line.alignment == Vertical.Alignment.center)
    }

    @Test
    func `Flow.Line bottom`() {
        let line: TestLayout.Flow<[String]>.Line = .bottom
        #expect(line.alignment == Vertical.Alignment.bottom)
    }
}

@Suite
struct `Layout.Flow.Gaps Tests` {
    @Test
    func `Gaps basic creation`() {
        let itemSpacing: TestLayout.Width = 8.0
        let lineSpacing: TestLayout.Height = 12.0

        let gaps: TestLayout.Flow<[String]>.Gaps = .init(item: itemSpacing, line: lineSpacing)

        #expect(gaps.item == itemSpacing)
        #expect(gaps.line == lineSpacing)
    }

    @Test
    func `Gaps uniform`() {
        let spacing: TestLayout.Spacing = 10.0

        let gaps: TestLayout.Flow<[String]>.Gaps = .uniform(spacing)

        #expect(gaps.item == spacing.width)
        #expect(gaps.line == spacing.height)
    }

    @Test
    func `Gaps Equatable`() {
        let gaps1: TestLayout.Flow<[String]>.Gaps = .init(item: 8.0, line: 12.0)
        let gaps2: TestLayout.Flow<[String]>.Gaps = .init(item: 8.0, line: 12.0)
        let gaps3: TestLayout.Flow<[String]>.Gaps = .init(item: 10.0, line: 12.0)

        #expect(gaps1 == gaps2)
        #expect(gaps1 != gaps3)
    }
}
