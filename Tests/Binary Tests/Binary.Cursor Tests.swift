import Testing

@testable import Binary

@Suite
struct `Binary.Cursor Tests` {

    // MARK: - Initialization

    @Test
    func `cursor initializes with default indices`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let cursor = Binary.Cursor(storage: storage)

        #expect(cursor.readerIndex == 0)
        #expect(cursor.writerIndex == 0)
        #expect(cursor.readableByteCount == 0)
        #expect(cursor.writableByteCount == 5)
    }

    @Test
    func `cursor initializes with custom indices`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let cursor = Binary.Cursor(storage: storage, readerIndex: 1, writerIndex: 4)

        #expect(cursor.readerIndex == 1)
        #expect(cursor.writerIndex == 4)
        #expect(cursor.readableByteCount == 3)
        #expect(cursor.writableByteCount == 1)
    }

    // MARK: - Index Mutation

    @Test
    func `moveReaderIndex advances reader`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 5)

        cursor.moveReaderIndex(by: 2)
        #expect(cursor.readerIndex == 2)
        #expect(cursor.readableByteCount == 3)
    }

    @Test
    func `moveWriterIndex advances writer`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 2)

        cursor.moveWriterIndex(by: 2)
        #expect(cursor.writerIndex == 4)
        #expect(cursor.writableByteCount == 1)
    }

    @Test
    func `setReaderIndex sets absolute position`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 5)

        cursor.setReaderIndex(to: 3)
        #expect(cursor.readerIndex == 3)
    }

    @Test
    func `setWriterIndex sets absolute position`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 2)

        cursor.setWriterIndex(to: 4)
        #expect(cursor.writerIndex == 4)
    }

    @Test
    func `reset clears both indices`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = Binary.Cursor(storage: storage, readerIndex: 2, writerIndex: 4)

        cursor.reset()
        #expect(cursor.readerIndex == 0)
        #expect(cursor.writerIndex == 0)
    }

    // MARK: - Readable/Writable Checks

    @Test
    func `isReadable returns true when bytes available`() {
        let storage: [UInt8] = [1, 2, 3]
        let cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 3)
        let isReadable = cursor.isReadable

        #expect(isReadable == true)
    }

    @Test
    func `isReadable returns false when no bytes available`() {
        let storage: [UInt8] = [1, 2, 3]
        let cursor = Binary.Cursor(storage: storage, readerIndex: 3, writerIndex: 3)
        let isReadable = cursor.isReadable

        #expect(isReadable == false)
    }

    @Test
    func `isWritable returns true when space available`() {
        let storage: [UInt8] = [1, 2, 3]
        let cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 1)
        let isWritable = cursor.isWritable

        #expect(isWritable == true)
    }

    @Test
    func `isWritable returns false when no space available`() {
        let storage: [UInt8] = [1, 2, 3]
        let cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 3)
        let isWritable = cursor.isWritable

        #expect(isWritable == false)
    }

    // MARK: - Closure-Based Access

    @Test
    func `withReadableBytes provides correct slice`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let cursor = Binary.Cursor(storage: storage, readerIndex: 1, writerIndex: 4)

        cursor.withReadableBytes { ptr in
            #expect(ptr.count == 3)
            #expect(ptr[0] == 2)
            #expect(ptr[1] == 3)
            #expect(ptr[2] == 4)
        }
    }

    @Test
    func `withWritableBytes provides correct slice`() {
        let storage: [UInt8] = [0, 0, 0, 0, 0]
        var cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 2)

        cursor.withWritableBytes { ptr in
            #expect(ptr.count == 3)
            ptr[0] = 42
            ptr[1] = 43
            ptr[2] = 44
        }

        #expect(cursor.storage[2] == 42)
        #expect(cursor.storage[3] == 43)
        #expect(cursor.storage[4] == 44)
    }

    // MARK: - Typed Throws

    @Test
    func `withReadableBytes propagates typed error`() {
        enum TestError: Error { case expected }

        let storage: [UInt8] = [1, 2, 3]
        let cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 3)

        #expect(throws: TestError.expected) {
            try cursor.withReadableBytes { (_: UnsafeRawBufferPointer) throws(TestError) in
                throw TestError.expected
            }
        }
    }

    @Test
    func `withWritableBytes propagates typed error`() {
        enum TestError: Error { case expected }

        let storage: [UInt8] = [1, 2, 3]
        var cursor = Binary.Cursor(storage: storage, readerIndex: 0, writerIndex: 0)

        #expect(throws: TestError.expected) {
            try cursor.withWritableBytes { (_: UnsafeMutableRawBufferPointer) throws(TestError) in
                throw TestError.expected
            }
        }
    }
}
