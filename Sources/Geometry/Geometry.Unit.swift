// Geometry.Unit.swift
// Marker protocol for geometry unit types.

//extension Geometry {
//    /// A marker protocol for geometry unit types.
//    ///
//    /// Types conforming to `Unit` can be used to parameterize
//    /// geometry primitives, providing type safety between different
//    /// coordinate systems.
//    ///
//    /// ## Example
//    ///
//    /// ```swift
//    /// struct PDFPoints: Geometry.Unit {
//    ///     let value: Double
//    ///     static var zero: PDFPoints { PDFPoints(value: 0) }
//    /// }
//    ///
//    /// struct CSSPixels: Geometry.Unit {
//    ///     let value: Double
//    ///     static var zero: CSSPixels { CSSPixels(value: 0) }
//    /// }
//    ///
//    /// // These are now distinct types that cannot be mixed
//    /// typealias PDFCoordinate = Geometry.Point<PDFPoints>
//    /// typealias CSSCoordinate = Geometry.Point<CSSPixels>
//    /// ```
//    public protocol Unit: Sendable, Hashable {}
//}
//
//// MARK: - Unitless
//
//extension Geometry {
//    /// A unitless marker type for generic utilities and tests.
//    ///
//    /// Use `Unitless` when you need geometry types but don't have
//    /// a specific unit system, such as in generic algorithms or tests.
//    public enum Unitless: Unit {}
//}

// MARK: - Standard Type Conformances
//
//extension Double: Geometry.Unit {}
//extension Float: Geometry.Unit {}
//extension Int: Geometry.Unit {}
