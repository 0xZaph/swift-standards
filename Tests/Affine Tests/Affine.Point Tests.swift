// Affine.Point Tests.swift
// Tests for Affine.Point.swift

import Testing

@testable import Affine
@testable import Algebra
@testable import Algebra_Linear

@Suite("Affine.Point Tests")
struct AffinePointTests {
    typealias A = Affine<Double, Void>
    typealias L = Linear<Double, Void>
    typealias Point2 = A.Point<2>
    typealias Point3 = A.Point<3>
    typealias Point4 = A.Point<4>
    typealias Vec2 = L.Vector<2>
    typealias Vec3 = L.Vector<3>
    typealias X = A.X
    typealias Y = A.Y
    typealias Z = A.Z
    typealias W = A.W
    typealias Dx = L.Dx
    typealias Dy = L.Dy
    typealias Dz = L.Dz
    typealias Distance = A.Distance

    // MARK: - Construction Tests

    @Suite("Construction")
    struct ConstructionTests {
        @Test("2D point construction with typed X/Y")
        func point2DTyped() {
            let x: X = 3
            let y: Y = 4
            let p = Point2(x: x, y: y)
            #expect(p.x == 3)
            #expect(p.y == 4)
        }

        @Test("2D point construction with literals")
        func point2DLiterals() {
            let p = Point2(x: 3, y: 4)
            #expect(p.x == 3)
            #expect(p.y == 4)
        }

        @Test("3D point construction")
        func point3D() {
            let p = Point3(x: 1, y: 2, z: 3)
            #expect(p.x == 1)
            #expect(p.y == 2)
            #expect(p.z == 3)
        }

        @Test("3D point from 2D point and z")
        func point3DFrom2D() {
            let p2 = Point2(x: 1, y: 2)
            let z: Z = 3
            let p3 = Point3(p2, z: z)
            #expect(p3.x == 1)
            #expect(p3.y == 2)
            #expect(p3.z == 3)
        }

        @Test("4D point construction")
        func point4D() {
            let p = Point4(x: 1, y: 2, z: 3, w: 4)
            #expect(p.x == 1)
            #expect(p.y == 2)
            #expect(p.z == 3)
            #expect(p.w == 4)
        }

        @Test("4D point from 3D point and w")
        func point4DFrom3D() {
            let p3 = Point3(x: 1, y: 2, z: 3)
            let w: W = 4
            let p4 = Point4(p3, w: w)
            #expect(p4.x == 1)
            #expect(p4.y == 2)
            #expect(p4.z == 3)
            #expect(p4.w == 4)
        }

        @Test("Point from coordinates array")
        func fromArray() {
            var coords = InlineArray<2, Double>(repeating: 0)
            coords[0] = 1
            coords[1] = 2
            let p = Point2(coords)
            #expect(p.x == 1)
            #expect(p.y == 2)
        }
    }

    // MARK: - Zero/Origin Tests

    @Suite("Zero")
    struct ZeroTests {
        @Test("2D zero point")
        func zero2D() {
            let origin = Point2.zero
            #expect(origin.x == 0)
            #expect(origin.y == 0)
        }

        @Test("3D zero point")
        func zero3D() {
            let origin = Point3.zero
            #expect(origin.x == 0)
            #expect(origin.y == 0)
            #expect(origin.z == 0)
        }
    }

    // MARK: - Affine Arithmetic Tests

    @Suite("Affine Arithmetic")
    struct AffineArithmeticTests {
        @Test("Point - Point = Vector", arguments: [
            (Point2(x: 5, y: 8), Point2(x: 2, y: 3), 3 as Dx, 5 as Dy),
            (Point2(x: 0, y: 0), Point2(x: 1, y: 1), -1 as Dx, -1 as Dy),
            (Point2(x: 10, y: 20), Point2(x: 10, y: 20), 0 as Dx, 0 as Dy)
        ])
        func pointMinusPoint(p1: Point2, p2: Point2, expectedDx: Dx, expectedDy: Dy) {
            let v: Vec2 = p1 - p2
            #expect(v.dx == expectedDx)
            #expect(v.dy == expectedDy)
        }

        @Test("Point + Vector = Point", arguments: [
            (Point2(x: 1, y: 2), Vec2(dx: 3, dy: 4), 4 as X, 6 as Y),
            (Point2(x: 0, y: 0), Vec2(dx: 1, dy: 1), 1 as X, 1 as Y),
            (Point2(x: -5, y: -3), Vec2(dx: 5, dy: 3), 0 as X, 0 as Y)
        ])
        func pointPlusVector(p: Point2, v: Vec2, expectedX: X, expectedY: Y) {
            let result: Point2 = p + v
            #expect(result.x == expectedX)
            #expect(result.y == expectedY)
        }

        @Test("Point - Vector = Point", arguments: [
            (Point2(x: 5, y: 6), Vec2(dx: 2, dy: 3), 3 as X, 3 as Y),
            (Point2(x: 0, y: 0), Vec2(dx: 1, dy: 1), -1 as X, -1 as Y)
        ])
        func pointMinusVector(p: Point2, v: Vec2, expectedX: X, expectedY: Y) {
            let result: Point2 = p - v
            #expect(result.x == expectedX)
            #expect(result.y == expectedY)
        }
    }

    // MARK: - Translation Tests

    @Suite("Translation")
    struct TranslationTests {
        @Test("Translate by deltas (2D)")
        func translateByDeltas2D() {
            let p = Point2(x: 1, y: 2)
            let translated = Point2.translated(p, dx: 3, dy: 4)
            #expect(translated.x == 4)
            #expect(translated.y == 6)
        }

        @Test("Translate by deltas instance method (2D)")
        func translateByDeltasInstance2D() {
            let p = Point2(x: 1, y: 2)
            let translated = p.translated(dx: 3, dy: 4)
            #expect(translated.x == 4)
            #expect(translated.y == 6)
        }

        @Test("Translate by vector (2D)")
        func translateByVector2D() {
            let p = Point2(x: 1, y: 2)
            let v = Vec2(dx: 3, dy: 4)
            let translated = Point2.translated(p, by: v)
            #expect(translated.x == 4)
            #expect(translated.y == 6)
        }

        @Test("Translate by vector instance method (2D)")
        func translateByVectorInstance2D() {
            let p = Point2(x: 1, y: 2)
            let v = Vec2(dx: 3, dy: 4)
            let translated = p.translated(by: v)
            #expect(translated.x == 4)
            #expect(translated.y == 6)
        }

        @Test("Translate by deltas (3D)")
        func translateByDeltas3D() {
            let p = Point3(x: 1, y: 2, z: 3)
            let translated = Point3.translated(p, dx: 1, dy: 2, dz: 3)
            #expect(translated.x == 2)
            #expect(translated.y == 4)
            #expect(translated.z == 6)
        }

        @Test("Translate by vector (3D)")
        func translateByVector3D() {
            let p = Point3(x: 1, y: 2, z: 3)
            let v = Vec3(dx: 1, dy: 2, dz: 3)
            let translated = Point3.translated(p, by: v)
            #expect(translated.x == 2)
            #expect(translated.y == 4)
            #expect(translated.z == 6)
        }
    }

    // MARK: - Vector Between Points Tests

    @Suite("Vector Between Points")
    struct VectorTests {
        @Test("Vector from point to another (2D)")
        func vector2D() {
            let p1 = Point2(x: 1, y: 2)
            let p2 = Point2(x: 4, y: 6)
            let v = Point2.vector(from: p1, to: p2)
            #expect(v.dx == 3)
            #expect(v.dy == 4)
        }

        @Test("Vector to another point (2D)")
        func vectorInstance2D() {
            let p1 = Point2(x: 1, y: 2)
            let p2 = Point2(x: 4, y: 6)
            let v = p1.vector(to: p2)
            #expect(v.dx == 3)
            #expect(v.dy == 4)
        }

        @Test("Vector from point to another (3D)")
        func vector3D() {
            let p1 = Point3(x: 1, y: 2, z: 3)
            let p2 = Point3(x: 4, y: 6, z: 9)
            let v = Point3.vector(from: p1, to: p2)
            #expect(v.dx == 3)
            #expect(v.dy == 4)
            #expect(v.dz == 6)
        }
    }

    // MARK: - Distance Tests

    @Suite("Distance")
    struct DistanceTests {
        @Test("Distance squared (2D)", arguments: [
            (Point2(x: 0, y: 0), Point2(x: 3, y: 4), 25.0),
            (Point2(x: 1, y: 1), Point2(x: 4, y: 5), 25.0),
            (Point2(x: 0, y: 0), Point2(x: 0, y: 0), 0.0)
        ])
        func distanceSquared2D(p1: Point2, p2: Point2, expected: Double) {
            let distSq = Point2.distanceSquared(from: p1, to: p2)
            #expect(distSq == expected)
        }

        @Test("Distance squared instance method (2D)")
        func distanceSquaredInstance2D() {
            let p1 = Point2(x: 0, y: 0)
            let p2 = Point2(x: 3, y: 4)
            #expect(p1.distanceSquared(to: p2) == 25)
        }

        @Test("Distance (2D)", arguments: [
            (Point2(x: 0, y: 0), Point2(x: 3, y: 4), 5 as Distance),
            (Point2(x: 0, y: 0), Point2(x: 1, y: 0), 1 as Distance),
            (Point2(x: 0, y: 0), Point2(x: 0, y: 0), 0 as Distance)
        ])
        func distance2D(p1: Point2, p2: Point2, expected: Distance) {
            let dist = Point2.distance(from: p1, to: p2)
            #expect(dist == expected)
        }

        @Test("Distance instance method (2D)")
        func distanceInstance2D() {
            let p1 = Point2(x: 0, y: 0)
            let p2 = Point2(x: 3, y: 4)
            let expected: Distance = 5
            #expect(p1.distance(to: p2) == expected)
        }

        @Test("Distance squared (3D)")
        func distanceSquared3D() {
            let p1 = Point3(x: 0, y: 0, z: 0)
            let p2 = Point3(x: 1, y: 2, z: 2)
            #expect(Point3.distanceSquared(from: p1, to: p2) == 9)
        }

        @Test("Distance (3D)")
        func distance3D() {
            let p1 = Point3(x: 0, y: 0, z: 0)
            let p2 = Point3(x: 1, y: 2, z: 2)
            let expected: Distance = 3
            #expect(Point3.distance(from: p1, to: p2) == expected)
        }
    }

    // MARK: - Interpolation Tests

    @Suite("Interpolation")
    struct InterpolationTests {
        @Test("Linear interpolation", arguments: [
            (Point2(x: 0, y: 0), Point2(x: 10, y: 20), 0.0, 0 as X, 0 as Y),
            (Point2(x: 0, y: 0), Point2(x: 10, y: 20), 0.5, 5 as X, 10 as Y),
            (Point2(x: 0, y: 0), Point2(x: 10, y: 20), 1.0, 10 as X, 20 as Y),
            (Point2(x: 0, y: 0), Point2(x: 10, y: 20), 0.25, 2.5 as X, 5 as Y)
        ])
        func lerp(p1: Point2, p2: Point2, t: Double, expectedX: X, expectedY: Y) {
            let result = Point2.lerp(from: p1, to: p2, t: t)
            #expect(result.x == expectedX)
            #expect(result.y == expectedY)
        }

        @Test("Linear interpolation instance method")
        func lerpInstance() {
            let p1 = Point2(x: 0, y: 0)
            let p2 = Point2(x: 10, y: 20)
            let mid = p1.lerp(to: p2, t: 0.5)
            #expect(mid.x == 5)
            #expect(mid.y == 10)
        }

        @Test("Midpoint", arguments: [
            (Point2(x: 0, y: 0), Point2(x: 10, y: 20), 5 as X, 10 as Y),
            (Point2(x: -5, y: -10), Point2(x: 5, y: 10), 0 as X, 0 as Y),
            (Point2(x: 1, y: 3), Point2(x: 5, y: 7), 3 as X, 5 as Y)
        ])
        func midpoint(p1: Point2, p2: Point2, expectedX: X, expectedY: Y) {
            let mid = Point2.midpoint(from: p1, to: p2)
            #expect(mid.x == expectedX)
            #expect(mid.y == expectedY)
        }

        @Test("Midpoint instance method")
        func midpointInstance() {
            let p1 = Point2(x: 0, y: 0)
            let p2 = Point2(x: 10, y: 20)
            let mid = p1.midpoint(to: p2)
            #expect(mid.x == 5)
            #expect(mid.y == 10)
        }
    }

    // MARK: - Equatable Tests

    @Suite("Equatable")
    struct EquatableTests {
        @Test("Point equality (2D)")
        func equality2D() {
            let a = Point2(x: 1, y: 2)
            let b = Point2(x: 1, y: 2)
            let c = Point2(x: 1, y: 3)
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Point equality (3D)")
        func equality3D() {
            let a = Point3(x: 1, y: 2, z: 3)
            let b = Point3(x: 1, y: 2, z: 3)
            let c = Point3(x: 1, y: 2, z: 4)
            #expect(a == b)
            #expect(a != c)
        }
    }

    // MARK: - Subscript Tests

    @Suite("Subscript")
    struct SubscriptTests {
        @Test("Subscript access and mutation")
        func `subscript`() {
            var p = Point2(x: 1, y: 2)
            #expect(p[0] == 1)
            #expect(p[1] == 2)

            p[0] = 10
            p[1] = 20
            #expect(p[0] == 10)
            #expect(p[1] == 20)
        }
    }

    // MARK: - Map Tests

    @Suite("Map")
    struct MapTests {
        @Test("Map transforms each coordinate")
        func map() throws {
            let p = Point2(x: 3, y: 4)
            let doubled: Affine<Int, Void>.Point<2> = p.map { Int($0 * 2) }
            #expect(doubled[0] == 6)
            #expect(doubled[1] == 8)
        }

        @Test("Map via init")
        func mapInit() throws {
            let p = Point2(x: 3, y: 4)
            let doubled = Affine<Int, Void>.Point<2>(p) { Int($0 * 2) }
            #expect(doubled[0] == 6)
            #expect(doubled[1] == 8)
        }
    }

    // MARK: - Zip Tests

    @Suite("Zip")
    struct ZipTests {
        @Test("Zip combines points component-wise")
        func zip() {
            let a = Point2(x: 1, y: 2)
            let b = Point2(x: 10, y: 20)
            let result = Point2.zip(a, b) { $0 + $1 }
            #expect(result.x == 11)
            #expect(result.y == 22)
        }
    }
}
