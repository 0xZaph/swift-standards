extension Binary {
    /// A type that provides read-only access to its contiguous bytes.
    ///
    /// Conforming types guarantee that bytes are laid out contiguously in memory
    /// and provide safe, scoped access.
    ///
    /// ## Normative vs Derived APIs
    ///
    /// - **Normative:** `withUnsafeBytes` is the normative access primitive.
    ///   It provides structurally lifetime-bounded access that is correct across
    ///   all generic and witness contexts.
    /// - **Derived:** `bytes` is a derived convenience view. Prefer it for most
    ///   algorithms, but fall back to closure APIs when span composition is not
    ///   expressible or when typed throws must propagate through witness boundaries.
    ///
    /// ## Invariants
    ///
    /// - `count >= 0`
    /// - `withUnsafeBytes` passes a buffer whose `.count == self.count`
    /// - `bytes.count == self.count`
    ///
    /// The pointer passed to the closure is only valid for the duration of the call.
    /// Do not store or return the pointer.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Preferred: use Span for most algorithms
    /// func checksum<T: Binary.Contiguous>(_ data: borrowing T) -> UInt32 {
    ///     data.bytes.reduce(0) { $0 &+ UInt32($1) }
    /// }
    ///
    /// // Escape hatch: use closure for interop or witness boundary cases
    /// func checksumViaPointer<T: Binary.Contiguous>(_ data: T) -> UInt32 {
    ///     data.withUnsafeBytes { ptr in
    ///         ptr.reduce(0) { $0 &+ UInt32($1) }
    ///     }
    /// }
    /// ```
    public protocol Contiguous: ~Copyable {
        /// The number of bytes in the buffer.
        ///
        /// This value is always non-negative and matches the count of the
        /// buffer pointer passed to `withUnsafeBytes`.
        var count: Int { get }

        /// Calls the given closure with a pointer to the contiguous bytes.
        ///
        /// - Parameter body: A closure that receives the buffer pointer.
        /// - Returns: The value returned by the closure.
        /// - Throws: The error thrown by the closure.
        func withUnsafeBytes<R, E: Swift.Error>(
            _ body: (UnsafeRawBufferPointer) throws(E) -> R
        ) throws(E) -> R

        /// Read-only span of the buffer as bytes (derived convenience view).
        ///
        /// Prefer this property for most algorithms. Fall back to `withUnsafeBytes`
        /// when span composition is not expressible or when typed throws must
        /// propagate through witness boundaries.
        ///
        /// The span is lifetime-dependent on `self`. Conformers must use
        /// `@_lifetime(borrow self)` on the getter implementation.
        ///
        /// ## Lifetime Contract
        ///
        /// - The span is valid ONLY for the duration of the borrow of `self`.
        /// - The span MUST NOT be stored, returned, or allowed to escape.
        var bytes: Span<UInt8> { get }
    }
}
