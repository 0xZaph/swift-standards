extension Binary {
    /// A position-tracked view over mutable contiguous storage.
    ///
    /// `Cursor` provides reader and writer indices over any `Binary.Mutable`
    /// storage without imposing allocation, growth, or compaction policies.
    ///
    /// ## Invariants (Enforced)
    ///
    /// - `0 <= readerIndex <= writerIndex <= storage.count` — ALWAYS
    /// - Violating bounds via mutation methods triggers a precondition failure.
    /// - No allocation occurs; storage is owned, not copied.
    /// - No policy decisions (growth, compaction) are made.
    ///
    /// ## Region Access
    ///
    /// Readable and writable regions are exposed via closure-based APIs that
    /// provide region-limited buffer pointer access. The region is defined by
    /// indices and validated by invariants. The pointer is valid only within
    /// the closure scope.
    public struct Cursor<Storage: Binary.Mutable>: ~Copyable {
        /// The underlying storage.
        public var storage: Storage

        /// The current read position.
        public private(set) var readerIndex: Int

        /// The current write position.
        public private(set) var writerIndex: Int

        /// Creates a cursor over the given storage.
        ///
        /// - Parameters:
        ///   - storage: The mutable storage to wrap.
        ///   - readerIndex: Initial read position. Default is 0.
        ///   - writerIndex: Initial write position. Default is 0.
        /// - Precondition: `0 <= readerIndex <= writerIndex <= storage.count`
        public init(storage: consuming Storage, readerIndex: Int = 0, writerIndex: Int = 0) {
            precondition(readerIndex >= 0, "readerIndex must be non-negative")
            precondition(writerIndex >= readerIndex, "writerIndex must be >= readerIndex")
            precondition(writerIndex <= storage.count, "writerIndex must be <= storage.count")
            self.storage = storage
            self.readerIndex = readerIndex
            self.writerIndex = writerIndex
        }

        /// Bytes available for reading: `readerIndex..<writerIndex`
        @inlinable
        public var readableByteCount: Int {
            writerIndex - readerIndex
        }

        /// Bytes available for writing: `writerIndex..<storage.count`
        @inlinable
        public var writableByteCount: Int {
            storage.count - writerIndex
        }
    }
}

// MARK: - Index Mutation

extension Binary.Cursor {
    /// Move reader index forward by `offset` bytes.
    ///
    /// - Parameter offset: The number of bytes to advance (can be negative for rewind).
    /// - Precondition: `0 <= readerIndex + offset <= writerIndex`
    public mutating func moveReaderIndex(by offset: Int) {
        let newIndex = readerIndex + offset
        precondition(newIndex >= 0, "Cannot move readerIndex below 0")
        precondition(newIndex <= writerIndex, "Cannot move readerIndex past writerIndex")
        readerIndex = newIndex
    }

    /// Move writer index forward by `offset` bytes.
    ///
    /// - Parameter offset: The number of bytes to advance (can be negative to discard).
    /// - Precondition: `readerIndex <= writerIndex + offset <= storage.count`
    public mutating func moveWriterIndex(by offset: Int) {
        let newIndex = writerIndex + offset
        precondition(newIndex >= readerIndex, "Cannot move writerIndex below readerIndex")
        precondition(newIndex <= storage.count, "Cannot move writerIndex past storage.count")
        writerIndex = newIndex
    }

    /// Set reader index to absolute position.
    ///
    /// - Parameter index: The new reader position.
    /// - Precondition: `0 <= index <= writerIndex`
    public mutating func setReaderIndex(to index: Int) {
        precondition(index >= 0, "readerIndex must be non-negative")
        precondition(index <= writerIndex, "readerIndex must be <= writerIndex")
        readerIndex = index
    }

    /// Set writer index to absolute position.
    ///
    /// - Parameter index: The new writer position.
    /// - Precondition: `readerIndex <= index <= storage.count`
    public mutating func setWriterIndex(to index: Int) {
        precondition(index >= readerIndex, "writerIndex must be >= readerIndex")
        precondition(index <= storage.count, "writerIndex must be <= storage.count")
        writerIndex = index
    }

    /// Reset both indices to zero.
    public mutating func reset() {
        readerIndex = 0
        writerIndex = 0
    }
}

// MARK: - Region Access

extension Binary.Cursor {
    /// Provides read-only access to the readable bytes region.
    ///
    /// The readable region is `storage[readerIndex..<writerIndex]`.
    /// The buffer pointer is valid only within the closure scope.
    ///
    /// - Parameter body: A closure that receives the readable bytes.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by the closure.
    @inlinable
    public func withReadableBytes<R, E: Swift.Error>(
        _ body: (UnsafeRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        try storage.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) throws(E) -> R in
            let slice = UnsafeRawBufferPointer(rebasing: ptr[readerIndex..<writerIndex])
            return try body(slice)
        }
    }

    /// Provides mutable access to the writable bytes region.
    ///
    /// The writable region is `storage[writerIndex..<storage.count]`.
    /// The buffer pointer is valid only within the closure scope.
    ///
    /// - Parameter body: A closure that receives the writable bytes.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by the closure.
    @inlinable
    public mutating func withWritableBytes<R, E: Swift.Error>(
        _ body: (UnsafeMutableRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        let writerIdx = writerIndex
        let storageCount = storage.count
        return try storage.withUnsafeMutableBytes {
            (ptr: UnsafeMutableRawBufferPointer) throws(E) -> R in
            let slice = UnsafeMutableRawBufferPointer(rebasing: ptr[writerIdx..<storageCount])
            return try body(slice)
        }
    }
}

// MARK: - Convenience

extension Binary.Cursor {
    /// Whether there are bytes available to read.
    @inlinable
    public var isReadable: Bool {
        readableByteCount > 0
    }

    /// Whether there is space available to write.
    @inlinable
    public var isWritable: Bool {
        writableByteCount > 0
    }
}
