import Formatting
import Testing

@Suite
struct `Bytes+Formatting Tests` {

    // MARK: - Basic Decimal Formatting

    @Test
    func `Basic byte formatting`() {
        #expect(0.formatted(.bytes) == "0 B")
        #expect(512.formatted(.bytes) == "512 B")
        #expect(999.formatted(.bytes) == "999 B")
    }

    @Test
    func `Kilobyte formatting`() {
        #expect(1000.formatted(.bytes) == "1 KB")
        #expect(1500.formatted(.bytes) == "1.5 KB")
        #expect(500_000.formatted(.bytes) == "500 KB")
    }

    @Test
    func `Megabyte formatting`() {
        #expect(1_000_000.formatted(.bytes) == "1 MB")
        #expect(1_500_000.formatted(.bytes) == "1.5 MB")
        #expect(500_000_000.formatted(.bytes) == "500 MB")
    }

    @Test
    func `Gigabyte formatting`() {
        #expect(1_000_000_000.formatted(.bytes) == "1 GB")
        #expect(1_500_000_000.formatted(.bytes) == "1.5 GB")
    }

    @Test
    func `Terabyte formatting`() {
        #expect(1_000_000_000_000.formatted(.bytes) == "1 TB")
        #expect(2_500_000_000_000.formatted(.bytes) == "2.5 TB")
    }

    // MARK: - Binary Unit Formatting

    @Test
    func `Binary unit formatting`() {
        #expect(1024.formatted(.bytes(.binary)) == "1 KiB")
        #expect(1536.formatted(.bytes(.binary)) == "1.5 KiB")
        #expect(1_048_576.formatted(.bytes(.binary)) == "1 MiB")
        #expect(1_073_741_824.formatted(.bytes(.binary)) == "1 GiB")
    }

    @Test
    func `Decimal vs binary difference`() {
        // 1024 bytes shows different values in each system
        #expect(1024.formatted(.bytes(.decimal)) == "1.02 KB")
        #expect(1024.formatted(.bytes(.binary)) == "1 KiB")

        // 1000 bytes
        #expect(1000.formatted(.bytes(.decimal)) == "1 KB")
        #expect(1000.formatted(.bytes(.binary)) == "1000 B")
    }

    // MARK: - Precision Control

    @Test
    func `Precision formatting`() {
        #expect(1536.formatted(.bytes.precision(0)) == "2 KB")
        #expect(1536.formatted(.bytes.precision(1)) == "1.5 KB")
        #expect(1536.formatted(.bytes.precision(2)) == "1.54 KB")
        #expect(1536.formatted(.bytes.precision(3)) == "1.536 KB")
    }

    @Test
    func `Auto precision strips trailing zeros`() {
        #expect(1000.formatted(.bytes) == "1 KB")
        #expect(1100.formatted(.bytes) == "1.1 KB")
        #expect(1120.formatted(.bytes) == "1.12 KB")
    }

    // MARK: - Notation Styles

    @Test
    func `Spaced notation`() {
        #expect(1024.formatted(.bytes.notation(.spaced)) == "1.02 KB")
        #expect(1_000_000.formatted(.bytes.notation(.spaced)) == "1 MB")
    }

    @Test
    func `Compact notation`() {
        #expect(1024.formatted(.bytes.notation(.compactName)) == "1.02KB")
        #expect(1_000_000.formatted(.bytes.notation(.compactName)) == "1MB")
    }

    // MARK: - Chaining

    @Test
    func `Chained configuration`() {
        let format = Format.Bytes.bytes(.binary).precision(2).notation(.compactName)
        #expect(1536.formatted(format) == "1.50KiB")
    }

    @Test
    func `Units via function`() {
        #expect(1024.formatted(.bytes(.binary)) == "1 KiB")
        #expect(1024.formatted(.bytes(.decimal)) == "1.02 KB")
    }

    @Test
    func `Units via chaining`() {
        #expect(1024.formatted(.bytes.units(.binary)) == "1 KiB")
        #expect(1024.formatted(.bytes.units(.decimal)) == "1.02 KB")
    }

    // MARK: - Without Unit

    @Test
    func `Without unit suffix`() {
        #expect(1024.formatted(.bytes.withoutUnit()) == "1.02")
        #expect(1_000_000.formatted(.bytes.withoutUnit()) == "1")
    }

    // MARK: - Edge Cases

    @Test
    func `Zero bytes`() {
        #expect(0.formatted(.bytes) == "0 B")
        #expect(0.formatted(.bytes(.binary)) == "0 B")
    }

    @Test
    func `Negative bytes`() {
        #expect((-1024).formatted(.bytes) == "-1.02 KB")
        #expect((-1024).formatted(.bytes(.binary)) == "-1 KiB")
    }

    @Test
    func `Large values`() {
        #expect(1_000_000_000_000_000.formatted(.bytes) == "1 PB")
        #expect(1_125_899_906_842_624.formatted(.bytes(.binary)) == "1 PiB")
    }

    // MARK: - Different Integer Types

    @Test
    func `Various integer types`() {
        #expect(UInt8(255).formatted(.bytes) == "255 B")
        #expect(Int16(1000).formatted(.bytes) == "1 KB")
        #expect(UInt32(1_000_000).formatted(.bytes) == "1 MB")
        #expect(Int64(1_000_000_000).formatted(.bytes) == "1 GB")
    }
}
