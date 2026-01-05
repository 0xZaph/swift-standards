// Binary.Cursor.swift
// Position-tracked view with typed throws.

extension Binary {
    /// A position-tracked view over mutable contiguous storage.
    ///
    /// Uses typed throws for all validation. All index arithmetic uses
    /// overflow-checking operations to prevent silent traps.
    ///
    /// ## Initializer Pattern
    ///
    /// - **Default**: `init(storage:)` — indices at zero, non-throwing
    /// - **Validated**: `init(storage:readerIndex:writerIndex:) throws` — validates at runtime
    /// - **Unchecked**: `init(__unchecked:storage:readerIndex:writerIndex:)` — precondition only
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Default (reader = 0, writer = 0)
    /// var cursor = Binary.Cursor(storage: buffer)
    ///
    /// // Validated (throws on invalid indices)
    /// var cursor = try Binary.Cursor(storage: buffer, readerIndex: 0, writerIndex: 10)
    ///
    /// // Unchecked (trusted caller)
    /// var cursor = Binary.Cursor(__unchecked: (), storage: buffer, readerIndex: 0, writerIndex: 10)
    /// ```
    ///
    /// ## Invariants
    ///
    /// `0 <= readerIndex <= writerIndex <= count`
    ///
    /// The `count` is stored as `Storage.Scalar` and validated once at construction.
    public struct Cursor<Storage: Binary.Mutable>: ~Copyable {
        /// The underlying storage.
        public var storage: Storage

        /// The storage count as Scalar (computed once, validated).
        @usableFromInline
        internal let _count: Storage.Scalar

        /// The current read position (internal storage).
        @usableFromInline
        internal var _readerIndex: Binary.Position<Storage.Scalar, Storage.Space>

        /// The current write position (internal storage).
        @usableFromInline
        internal var _writerIndex: Binary.Position<Storage.Scalar, Storage.Space>

        /// The current read position.
        @inlinable
        public var readerIndex: Binary.Position<Storage.Scalar, Storage.Space> {
            _readerIndex
        }

        /// The current write position.
        @inlinable
        public var writerIndex: Binary.Position<Storage.Scalar, Storage.Space> {
            _writerIndex
        }

        /// The storage count.
        @inlinable
        public var count: Storage.Scalar {
            _count
        }
    }
}

// MARK: - Default Initializer

extension Binary.Cursor {
    /// Creates a cursor over the given storage with indices at zero.
    ///
    /// This is the simplest way to create a cursor. Both reader and writer
    /// start at position zero.
    ///
    /// - Parameter storage: The underlying storage.
    /// - Throws: `Binary.Error.overflow` if storage.count exceeds Scalar range.
    @inlinable
    public init(storage: consuming Storage) throws(Binary.Error) {
        guard let count = Storage.Scalar(exactly: storage.count) else {
            throw .overflow(.init(operation: .conversion, field: .count))
        }
        self.storage = storage
        self._count = count
        self._readerIndex = 0
        self._writerIndex = 0
    }
}

// MARK: - Validated Initializer

extension Binary.Cursor {
    /// Creates a cursor over the given storage with validated indices.
    ///
    /// - Parameters:
    ///   - storage: The underlying storage.
    ///   - readerIndex: The initial reader position.
    ///   - writerIndex: The initial writer position.
    /// - Throws: `Binary.Error` if indices violate invariants or storage.count exceeds Scalar range.
    @inlinable
    public init(
        storage: consuming Storage,
        readerIndex: Binary.Position<Storage.Scalar, Storage.Space>,
        writerIndex: Binary.Position<Storage.Scalar, Storage.Space>
    ) throws(Binary.Error) {
        guard let count = Storage.Scalar(exactly: storage.count) else {
            throw .overflow(.init(operation: .conversion, field: .count))
        }

        guard readerIndex._rawValue >= 0 else {
            throw .negative(.init(field: .reader, value: readerIndex._rawValue))
        }

        guard writerIndex._rawValue >= readerIndex._rawValue else {
            throw .invariant(.init(
                kind: .reader,
                left: readerIndex._rawValue,
                right: writerIndex._rawValue
            ))
        }

        guard writerIndex._rawValue <= count else {
            throw .bounds(.init(
                field: .writer,
                value: writerIndex._rawValue,
                lower: Storage.Scalar(0),
                upper: count
            ))
        }

        self.storage = storage
        self._count = count
        self._readerIndex = readerIndex
        self._writerIndex = writerIndex
    }
}

// MARK: - Unchecked Initializer

extension Binary.Cursor {
    /// Creates a cursor without validation.
    ///
    /// Use this in performance-critical paths where invariants are
    /// guaranteed by construction or prior validation.
    ///
    /// - Parameters:
    ///   - __unchecked: Marker parameter (pass `()` or omit).
    ///   - storage: The underlying storage.
    ///   - readerIndex: The initial reader position.
    ///   - writerIndex: The initial writer position.
    /// - Precondition: `storage.count` must fit in `Storage.Scalar`.
    /// - Precondition: `0 <= readerIndex <= writerIndex <= storage.count`
    @inlinable
    public init(
        __unchecked: Void = (),
        storage: consuming Storage,
        readerIndex: Binary.Position<Storage.Scalar, Storage.Space>,
        writerIndex: Binary.Position<Storage.Scalar, Storage.Space>
    ) {
        let count = Storage.Scalar(exactly: storage.count)
        precondition(count != nil, "storage.count exceeds Scalar range")
        precondition(readerIndex._rawValue >= 0)
        precondition(writerIndex._rawValue >= readerIndex._rawValue)
        precondition(writerIndex._rawValue <= count!)
        self.storage = storage
        self._count = count!
        self._readerIndex = readerIndex
        self._writerIndex = writerIndex
    }
}

// MARK: - Computed Properties

extension Binary.Cursor {
    /// Bytes available for reading.
    @inlinable
    public var readableCount: Binary.Count<Storage.Scalar, Storage.Space> {
        // Safe: invariant guarantees writer >= reader
        Binary.Count(unchecked: _writerIndex._rawValue - _readerIndex._rawValue)
    }

    /// Bytes available for writing.
    @inlinable
    public var writableCount: Binary.Count<Storage.Scalar, Storage.Space> {
        // Safe: invariant guarantees count >= writer
        Binary.Count(unchecked: _count - _writerIndex._rawValue)
    }

    /// Whether there are bytes available to read.
    @inlinable
    public var isReadable: Bool {
        _writerIndex._rawValue > _readerIndex._rawValue
    }

    /// Whether there is space available to write.
    @inlinable
    public var isWritable: Bool {
        _count > _writerIndex._rawValue
    }
}

// MARK: - Move Reader Index

extension Binary.Cursor {
    /// Move reader index by offset.
    ///
    /// - Parameter offset: The displacement to apply.
    /// - Throws: `Binary.Error` if resulting index would be invalid or overflow occurs.
    @inlinable
    public mutating func moveReaderIndex(
        by offset: Binary.Offset<Storage.Scalar, Storage.Space>
    ) throws(Binary.Error) {
        let (newIndex, overflow) = _readerIndex._rawValue.addingReportingOverflow(offset._rawValue)

        guard !overflow else {
            throw .overflow(.init(operation: .addition, field: .reader))
        }

        guard newIndex >= 0 else {
            throw .bounds(.init(
                field: .reader,
                value: newIndex,
                lower: Storage.Scalar(0),
                upper: _writerIndex._rawValue
            ))
        }

        guard newIndex <= _writerIndex._rawValue else {
            throw .invariant(.init(
                kind: .reader,
                left: newIndex,
                right: _writerIndex._rawValue
            ))
        }

        _readerIndex = Binary.Position(newIndex)
    }

    /// Move reader index by offset (unchecked).
    ///
    /// - Parameters:
    ///   - __unchecked: Marker parameter (pass `()` or omit).
    ///   - offset: The displacement to apply.
    /// - Precondition: No overflow occurs.
    /// - Precondition: Result must satisfy `0 <= readerIndex <= writerIndex`.
    @inlinable
    public mutating func moveReaderIndex(
        __unchecked: Void = (),
        by offset: Binary.Offset<Storage.Scalar, Storage.Space>
    ) {
        let (newIndex, overflow) = _readerIndex._rawValue.addingReportingOverflow(offset._rawValue)
        precondition(!overflow, "readerIndex arithmetic overflow")
        precondition(newIndex >= 0 && newIndex <= _writerIndex._rawValue)
        _readerIndex = Binary.Position(newIndex)
    }
}

// MARK: - Move Writer Index

extension Binary.Cursor {
    /// Move writer index by offset.
    ///
    /// - Parameter offset: The displacement to apply.
    /// - Throws: `Binary.Error` if resulting index would be invalid or overflow occurs.
    @inlinable
    public mutating func moveWriterIndex(
        by offset: Binary.Offset<Storage.Scalar, Storage.Space>
    ) throws(Binary.Error) {
        let (newIndex, overflow) = _writerIndex._rawValue.addingReportingOverflow(offset._rawValue)

        guard !overflow else {
            throw .overflow(.init(operation: .addition, field: .writer))
        }

        guard newIndex >= _readerIndex._rawValue else {
            throw .invariant(.init(
                kind: .reader,
                left: _readerIndex._rawValue,
                right: newIndex
            ))
        }

        guard newIndex <= _count else {
            throw .bounds(.init(
                field: .writer,
                value: newIndex,
                lower: _readerIndex._rawValue,
                upper: _count
            ))
        }

        _writerIndex = Binary.Position(newIndex)
    }

    /// Move writer index by offset (unchecked).
    ///
    /// - Parameters:
    ///   - __unchecked: Marker parameter (pass `()` or omit).
    ///   - offset: The displacement to apply.
    /// - Precondition: No overflow occurs.
    /// - Precondition: Result must satisfy `readerIndex <= writerIndex <= count`.
    @inlinable
    public mutating func moveWriterIndex(
        __unchecked: Void = (),
        by offset: Binary.Offset<Storage.Scalar, Storage.Space>
    ) {
        let (newIndex, overflow) = _writerIndex._rawValue.addingReportingOverflow(offset._rawValue)
        precondition(!overflow, "writerIndex arithmetic overflow")
        precondition(newIndex >= _readerIndex._rawValue)
        precondition(newIndex <= _count)
        _writerIndex = Binary.Position(newIndex)
    }
}

// MARK: - Set Reader Index

extension Binary.Cursor {
    /// Set reader index to position.
    ///
    /// - Parameter position: The new reader position.
    /// - Throws: `Binary.Error` if position is invalid.
    @inlinable
    public mutating func setReaderIndex(
        to position: Binary.Position<Storage.Scalar, Storage.Space>
    ) throws(Binary.Error) {
        guard position._rawValue >= 0 else {
            throw .negative(.init(field: .reader, value: position._rawValue))
        }

        guard position._rawValue <= _writerIndex._rawValue else {
            throw .invariant(.init(
                kind: .reader,
                left: position._rawValue,
                right: _writerIndex._rawValue
            ))
        }

        _readerIndex = position
    }

    /// Set reader index to position (unchecked).
    ///
    /// - Parameters:
    ///   - __unchecked: Marker parameter (pass `()` or omit).
    ///   - position: The new reader position.
    /// - Precondition: `0 <= position <= writerIndex`.
    @inlinable
    public mutating func setReaderIndex(
        __unchecked: Void = (),
        to position: Binary.Position<Storage.Scalar, Storage.Space>
    ) {
        precondition(position._rawValue >= 0)
        precondition(position._rawValue <= _writerIndex._rawValue)
        _readerIndex = position
    }
}

// MARK: - Set Writer Index

extension Binary.Cursor {
    /// Set writer index to position.
    ///
    /// - Parameter position: The new writer position.
    /// - Throws: `Binary.Error` if position is invalid.
    @inlinable
    public mutating func setWriterIndex(
        to position: Binary.Position<Storage.Scalar, Storage.Space>
    ) throws(Binary.Error) {
        guard position._rawValue >= _readerIndex._rawValue else {
            throw .invariant(.init(
                kind: .reader,
                left: _readerIndex._rawValue,
                right: position._rawValue
            ))
        }

        guard position._rawValue <= _count else {
            throw .bounds(.init(
                field: .writer,
                value: position._rawValue,
                lower: _readerIndex._rawValue,
                upper: _count
            ))
        }

        _writerIndex = position
    }

    /// Set writer index to position (unchecked).
    ///
    /// - Parameters:
    ///   - __unchecked: Marker parameter (pass `()` or omit).
    ///   - position: The new writer position.
    /// - Precondition: `readerIndex <= position <= count`.
    @inlinable
    public mutating func setWriterIndex(
        __unchecked: Void = (),
        to position: Binary.Position<Storage.Scalar, Storage.Space>
    ) {
        precondition(position._rawValue >= _readerIndex._rawValue)
        precondition(position._rawValue <= _count)
        _writerIndex = position
    }
}

// MARK: - Reset

extension Binary.Cursor {
    /// Reset both indices to zero.
    @inlinable
    public mutating func reset() {
        _readerIndex = 0
        _writerIndex = 0
    }
}

// MARK: - Region Access

extension Binary.Cursor {
    /// Provides read-only access to the readable bytes region.
    ///
    /// The readable region is `storage[readerIndex..<writerIndex]`.
    /// The buffer pointer is valid only within the closure scope.
    @inlinable
    public func withReadableBytes<R, E: Swift.Error>(
        _ body: (UnsafeRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        let readerIdx = Int(_readerIndex._rawValue)
        let writerIdx = Int(_writerIndex._rawValue)
        return try storage.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) throws(E) -> R in
            let slice = UnsafeRawBufferPointer(rebasing: ptr[readerIdx..<writerIdx])
            return try body(slice)
        }
    }

    /// Provides mutable access to the writable bytes region.
    ///
    /// The writable region is `storage[writerIndex..<count]`.
    /// The buffer pointer is valid only within the closure scope.
    @inlinable
    public mutating func withWritableBytes<R, E: Swift.Error>(
        _ body: (UnsafeMutableRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        let writerIdx = Int(_writerIndex._rawValue)
        let storageCount = Int(_count)
        return try storage.withUnsafeMutableBytes {
            (ptr: UnsafeMutableRawBufferPointer) throws(E) -> R in
            let slice = UnsafeMutableRawBufferPointer(rebasing: ptr[writerIdx..<storageCount])
            return try body(slice)
        }
    }
}
