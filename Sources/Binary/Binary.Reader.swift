extension Binary {
    /// A read-only position-tracked view over contiguous storage.
    ///
    /// `Reader` provides a reader index over any `Binary.Contiguous` storage
    /// without imposing any mutation on the underlying data.
    ///
    /// ## Invariants (Enforced)
    ///
    /// - `0 <= readerIndex <= storage.count` — ALWAYS
    /// - Violating bounds via mutation methods triggers a precondition failure.
    /// - Storage is immutable through the reader.
    ///
    /// ## Region Access
    ///
    /// Remaining bytes are exposed via a closure-based API that provides
    /// region-limited buffer pointer access. The region is defined by
    /// indices and validated by invariants. The pointer is valid only within
    /// the closure scope.
    public struct Reader<Storage: Binary.Contiguous>: ~Copyable {
        /// The underlying storage.
        public let storage: Storage

        /// The current read position.
        public private(set) var readerIndex: Int

        /// Creates a reader over the given storage.
        ///
        /// - Parameters:
        ///   - storage: The contiguous storage to wrap.
        ///   - readerIndex: Initial read position. Default is 0.
        /// - Precondition: `0 <= readerIndex <= storage.count`
        public init(storage: consuming Storage, readerIndex: Int = 0) {
            precondition(readerIndex >= 0, "readerIndex must be non-negative")
            precondition(readerIndex <= storage.count, "readerIndex must be <= storage.count")
            self.storage = storage
            self.readerIndex = readerIndex
        }

        /// Bytes remaining to read: `readerIndex..<storage.count`
        @inlinable
        public var remainingByteCount: Int {
            storage.count - readerIndex
        }
    }
}

// MARK: - Index Mutation

extension Binary.Reader {
    /// Move reader index forward by `offset` bytes.
    ///
    /// - Parameter offset: The number of bytes to advance (can be negative for rewind).
    /// - Precondition: `0 <= readerIndex + offset <= storage.count`
    public mutating func moveReaderIndex(by offset: Int) {
        let newIndex = readerIndex + offset
        precondition(newIndex >= 0, "Cannot move readerIndex below 0")
        precondition(newIndex <= storage.count, "Cannot move readerIndex past storage.count")
        readerIndex = newIndex
    }

    /// Set reader index to absolute position.
    ///
    /// - Parameter index: The new reader position.
    /// - Precondition: `0 <= index <= storage.count`
    public mutating func setReaderIndex(to index: Int) {
        precondition(index >= 0, "readerIndex must be non-negative")
        precondition(index <= storage.count, "readerIndex must be <= storage.count")
        readerIndex = index
    }

    /// Reset reader index to zero.
    public mutating func reset() {
        readerIndex = 0
    }
}

// MARK: - Region Access

extension Binary.Reader {
    /// Provides read-only access to the remaining bytes region.
    ///
    /// The remaining region is `storage[readerIndex..<storage.count]`.
    /// The buffer pointer is valid only within the closure scope.
    ///
    /// - Parameter body: A closure that receives the remaining bytes.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by the closure.
    @inlinable
    public func withRemainingBytes<R, E: Swift.Error>(
        _ body: (UnsafeRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        try storage.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) throws(E) -> R in
            let slice = UnsafeRawBufferPointer(rebasing: ptr[readerIndex..<storage.count])
            return try body(slice)
        }
    }
}

// MARK: - Convenience

extension Binary.Reader {
    /// Whether there are bytes remaining to read.
    @inlinable
    public var hasRemaining: Bool {
        remainingByteCount > 0
    }

    /// Whether the reader has consumed all bytes.
    @inlinable
    public var isAtEnd: Bool {
        readerIndex >= storage.count
    }
}
