import Testing

@testable import Binary

@Suite
struct `Binary.Reader Tests` {

    // MARK: - Initialization

    @Test
    func `reader initializes with default index`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = Binary.Reader(storage: storage)

        #expect(reader.readerIndex == 0)
        #expect(reader.remainingByteCount == 5)
    }

    @Test
    func `reader initializes with custom index`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = Binary.Reader(storage: storage, readerIndex: 2)

        #expect(reader.readerIndex == 2)
        #expect(reader.remainingByteCount == 3)
    }

    // MARK: - Index Mutation

    @Test
    func `moveReaderIndex advances reader`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = Binary.Reader(storage: storage)

        reader.moveReaderIndex(by: 3)
        #expect(reader.readerIndex == 3)
        #expect(reader.remainingByteCount == 2)
    }

    @Test
    func `moveReaderIndex allows negative offset (rewind)`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = Binary.Reader(storage: storage, readerIndex: 3)

        reader.moveReaderIndex(by: -2)
        #expect(reader.readerIndex == 1)
        #expect(reader.remainingByteCount == 4)
    }

    @Test
    func `setReaderIndex sets absolute position`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = Binary.Reader(storage: storage)

        reader.setReaderIndex(to: 4)
        #expect(reader.readerIndex == 4)
        #expect(reader.remainingByteCount == 1)
    }

    @Test
    func `reset clears reader index`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = Binary.Reader(storage: storage, readerIndex: 3)

        reader.reset()
        #expect(reader.readerIndex == 0)
        #expect(reader.remainingByteCount == 5)
    }

    // MARK: - Convenience Properties

    @Test
    func `hasRemaining returns true when bytes available`() {
        let storage: [UInt8] = [1, 2, 3]
        let reader = Binary.Reader(storage: storage)
        let hasRemaining = reader.hasRemaining

        #expect(hasRemaining == true)
    }

    @Test
    func `hasRemaining returns false at end`() {
        let storage: [UInt8] = [1, 2, 3]
        let reader = Binary.Reader(storage: storage, readerIndex: 3)
        let hasRemaining = reader.hasRemaining

        #expect(hasRemaining == false)
    }

    @Test
    func `isAtEnd returns true at end`() {
        let storage: [UInt8] = [1, 2, 3]
        let reader = Binary.Reader(storage: storage, readerIndex: 3)
        let isAtEnd = reader.isAtEnd

        #expect(isAtEnd == true)
    }

    @Test
    func `isAtEnd returns false when bytes remain`() {
        let storage: [UInt8] = [1, 2, 3]
        let reader = Binary.Reader(storage: storage)
        let isAtEnd = reader.isAtEnd

        #expect(isAtEnd == false)
    }

    // MARK: - Closure-Based Access

    @Test
    func `withRemainingBytes provides correct slice`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = Binary.Reader(storage: storage, readerIndex: 2)

        reader.withRemainingBytes { ptr in
            #expect(ptr.count == 3)
            #expect(ptr[0] == 3)
            #expect(ptr[1] == 4)
            #expect(ptr[2] == 5)
        }
    }

    @Test
    func `withRemainingBytes returns empty for exhausted reader`() {
        let storage: [UInt8] = [1, 2, 3]
        let reader = Binary.Reader(storage: storage, readerIndex: 3)

        reader.withRemainingBytes { ptr in
            #expect(ptr.isEmpty)
        }
    }

    // MARK: - Typed Throws

    @Test
    func `withRemainingBytes propagates typed error`() {
        enum TestError: Error { case expected }

        let storage: [UInt8] = [1, 2, 3]
        let reader = Binary.Reader(storage: storage)

        #expect(throws: TestError.expected) {
            try reader.withRemainingBytes { (_: UnsafeRawBufferPointer) throws(TestError) in
                throw TestError.expected
            }
        }
    }

    // MARK: - Storage Access

    @Test
    func `storage property provides access to underlying data`() {
        let storage: [UInt8] = [10, 20, 30]
        let reader = Binary.Reader(storage: storage)

        #expect(reader.storage.count == 3)
        #expect(reader.storage[0] == 10)
    }
}
