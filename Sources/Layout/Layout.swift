// Layout
//
// Compositional layout primitives parameterized by scalar type and coordinate space.

public import Geometry

/// Namespace for layout primitives that arrange content in space.
///
/// Provides container types (`Stack`, `Grid`, `Flow`) parameterized by scalar type
/// and coordinate space, mirroring `Geometry<Scalar, Space>`. Layout is the compositional
/// layer that arranges content within a geometric space.
///
/// ## Structure
///
/// Layout depends on and uses types from Geometry:
/// - `Width`, `Height`: Directional spacing dimensions
/// - `Spacing`: Non-directional magnitude for stack spacing
/// - `Point`, `Size`: Positions and dimensions
///
/// ## Example
///
/// ```swift
/// enum PageSpace {}
///
/// // Create specialized layout types
/// typealias PageLayout = Layout<Double, PageSpace>
/// typealias PageStack<C> = PageLayout.Stack<C>
/// typealias PageGrid<C> = PageLayout.Grid<C>
///
/// // Use them in your layouts
/// let vstack = PageStack<[View]>.vertical(
///     spacing: 16.0,
///     alignment: .leading,
///     content: views
/// )
/// ```
///
/// ## Mathematical Note
///
/// Layout types are *functors* mapping content to positioned geometry:
/// ```
/// Stack : (Content, Spacing) → [Position × Content]
/// Grid  : (Content, Gaps)    → [Position × Content]
/// ```
///
/// Layout uses geometry but is semantically distinct: geometry is the study of space,
/// layout is the compositional arrangement of content within that space.
public enum Layout<Scalar: ~Copyable, Space>: ~Copyable {}

extension Layout: Copyable where Scalar: Copyable {}
extension Layout: Sendable where Scalar: Sendable {}

// MARK: - Type Aliases (Geometric types for convenience)

extension Layout {
    /// Horizontal displacement/dimension.
    /// See ``Geometry/Width``
    public typealias Width = Geometry<Scalar, Space>.Width

    /// Vertical displacement/dimension.
    /// See ``Geometry/Height``
    public typealias Height = Geometry<Scalar, Space>.Height

    /// Non-directional spacing magnitude.
    /// Projects to Width or Height at usage based on axis.
    /// See ``Geometry/Magnitude``
    public typealias Spacing = Geometry<Scalar, Space>.Magnitude

    /// 2D position in space.
    /// See ``Geometry/Point``
    public typealias Point = Geometry<Scalar, Space>.Point<2>

    /// 2D dimensions.
    /// See ``Geometry/Size``
    public typealias Size = Geometry<Scalar, Space>.Size<2>
}
