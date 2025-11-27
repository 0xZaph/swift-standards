// UInt8.Streaming.swift
// swift-standards
//
// Streaming byte serialization protocol
//
// This protocol defines the fundamental abstraction for types that can
// serialize themselves into byte buffers. Unlike buffered serialization
// (which returns `[UInt8]`), streaming serialization writes directly into
// a caller-provided buffer, enabling:
//
// - Zero-copy composition of nested structures
// - Efficient memory usage for large documents
// - Progressive output (start writing before computation completes)
// - Compatibility with diverse buffer types (Data, ByteBuffer, etc.)
//
// ## Design Philosophy
//
// The protocol is intentionally minimal:
// - Single requirement: `serialize(into:)`
// - No context parameter (values are self-describing)
// - No associated error type (serialization is infallible for valid values)
// - Buffer-agnostic via `RangeReplaceableCollection`
//
// ## Category Theory
//
// Streaming serialization is a natural transformation:
// - **Domain**: Self (structured value)
// - **Codomain**: Mutation of Buffer (byte sequence)
//
// The `inout Buffer` pattern represents the state monad:
// serialize: Self → (Buffer → Buffer)
//
// Composition of streaming types corresponds to monad sequencing:
// parent.serialize ≡ writeOpen >> children.map(serialize) >> writeClose

extension UInt8 {
    /// Protocol for types that serialize to byte streams
    ///
    /// Conforming types can write their byte representation directly into
    /// any `RangeReplaceableCollection` of `UInt8`, enabling efficient
    /// composition and streaming output.
    ///
    /// ## Use Cases
    ///
    /// - HTML document streaming (server-side rendering)
    /// - Large structured data (JSON, XML, protocol buffers)
    /// - Compositional serialization (nested DOM-like structures)
    /// - HTTP chunked transfer encoding
    /// - Template rendering engines
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct HTMLDiv: UInt8.Streaming {
    ///     let className: String?
    ///     let children: [any UInt8.Streaming]
    ///
    ///     func serialize<Buffer: RangeReplaceableCollection>(
    ///         into buffer: inout Buffer
    ///     ) where Buffer.Element == UInt8 {
    ///         buffer.append(contentsOf: "<div".utf8)
    ///         if let className {
    ///             buffer.append(contentsOf: " class=\"".utf8)
    ///             buffer.append(contentsOf: className.utf8)
    ///             buffer.append(UInt8(ascii: "\""))
    ///         }
    ///         buffer.append(UInt8(ascii: ">"))
    ///
    ///         for child in children {
    ///             child.serialize(into: &buffer)
    ///         }
    ///
    ///         buffer.append(contentsOf: "</div>".utf8)
    ///     }
    /// }
    /// ```
    ///
    /// ## Buffer Types
    ///
    /// The generic constraint allows writing to:
    /// - `[UInt8]` — Standard byte array
    /// - `Data` — Foundation's data type (via adapter)
    /// - `ByteBuffer` — SwiftNIO's buffer type (via adapter)
    /// - Custom buffers for specialized use cases
    ///
    /// ## Composition
    ///
    /// Streaming types compose naturally:
    ///
    /// ```swift
    /// struct Document: UInt8.Streaming {
    ///     let header: Header      // also UInt8.Streaming
    ///     let body: Body          // also UInt8.Streaming
    ///
    ///     func serialize<Buffer: RangeReplaceableCollection>(
    ///         into buffer: inout Buffer
    ///     ) where Buffer.Element == UInt8 {
    ///         header.serialize(into: &buffer)
    ///         body.serialize(into: &buffer)
    ///     }
    /// }
    /// ```
    public protocol Serializable: Sendable {
        /// Serialize this value into a byte buffer
        ///
        /// Appends the byte representation of this value to the provided buffer.
        /// The buffer is mutated in place for efficiency.
        ///
        /// - Parameter buffer: The buffer to append bytes to
        ///
        /// ## Implementation Notes
        ///
        /// - Append bytes using `buffer.append(contentsOf:)` for sequences
        /// - Use `buffer.append(_:)` for single bytes
        /// - Call `child.serialize(into: &buffer)` for nested streaming types
        /// - Do not clear or replace the buffer contents
        func serialize<Buffer: RangeReplaceableCollection>(
            into buffer: inout Buffer
        ) where Buffer.Element == UInt8
    }
}

// MARK: - Convenience Extensions

extension UInt8.Serializable {
    /// Serialize to a new byte array
    ///
    /// Convenience method that creates a buffer and returns the result.
    /// For repeated serialization or large outputs, prefer `serialize(into:)`
    /// with a pre-allocated or reusable buffer.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let html: HTMLDocument = ...
    /// let bytes = html.bytes  // [UInt8]
    /// ```
    public var bytes: [UInt8] {
        var buffer: [UInt8] = []
        serialize(into: &buffer)
        return buffer
    }

    /// Serialize to a new byte array with capacity hint
    ///
    /// When you know the approximate output size, providing a capacity
    /// hint avoids buffer reallocations during serialization.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let html: HTMLDocument = ...
    /// let bytes = html.bytes(reservingCapacity: 4096)
    /// ```
    ///
    /// - Parameter capacity: Initial buffer capacity
    /// - Returns: Serialized byte array
    public func bytes(reservingCapacity capacity: Int) -> [UInt8] {
        var buffer: [UInt8] = []
        buffer.reserveCapacity(capacity)
        serialize(into: &buffer)
        return buffer
    }
}

// MARK: - String Conversion

extension StringProtocol {
    /// Create a string from a streaming value's UTF-8 output
    ///
    /// Serializes the value and interprets the bytes as UTF-8.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let html: HTMLDocument = ...
    /// let string = String(html)
    /// ```
    ///
    /// - Parameter value: The streaming value to convert
    public init<T: UInt8.Serializable>(_ value: T) {
        self = Self(decoding: value.bytes, as: UTF8.self)
    }
}

// MARK: - Static Serialize Convenience

extension UInt8.Serializable {
    /// Static serialization function matching UInt8.ASCII.Serializable style
    ///
    /// Provides API compatibility with `UInt8.ASCII.Serializable`:
    ///
    /// ```swift
    /// let bytes = HTMLDocument.serialize(document)
    /// ```
    public static var serialize: @Sendable (Self) -> [UInt8] {
        { $0.bytes }
    }
}
