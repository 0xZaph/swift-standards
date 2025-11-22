// Instant.swift
// StandardTime
//
// Point on the UTC timeline

/// A point on the UTC timeline
///
/// Represents an absolute moment in time as seconds and nanoseconds since
/// Unix epoch (1970-01-01 00:00:00 UTC). Suitable for:
/// - Timeline arithmetic (adding/subtracting durations)
/// - Comparisons (before/after)
/// - Serialization (compact representation)
///
/// For calendar operations (year, month, day), convert to `Time`.
///
/// ## Usage
///
/// ```swift
/// // Timeline arithmetic
/// let now = Instant(secondsSinceUnixEpoch: 1732276800)
/// let later = now + .seconds(3600)
/// let duration = later - now
///
/// // Conversion to/from Time
/// let time = try Time(year: 2024, month: 11, day: 22, hour: 10, minute: 0, second: 0)
/// let instant = Instant(time)
/// let backToTime = Time(instant)
/// ```
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public struct Instant: Sendable, Equatable, Hashable, Comparable, Codable {
    /// Seconds since Unix epoch (1970-01-01 00:00:00 UTC)
    public let secondsSinceUnixEpoch: Int64

    /// Nanosecond fraction within the second (0-999,999,999)
    public let nanosecondFraction: Int32

    /// Create an instant from seconds and nanoseconds
    ///
    /// - Parameters:
    ///   - secondsSinceUnixEpoch: Seconds since Unix epoch (1970-01-01 00:00:00 UTC)
    ///   - nanosecondFraction: Nanosecond fraction within the second (0-999,999,999)
    /// - Throws: `Instant.Error.nanosecondOutOfRange` if nanosecondFraction is not in valid range
    public init(secondsSinceUnixEpoch: Int64, nanosecondFraction: Int32 = 0) throws {
        guard nanosecondFraction >= 0 && nanosecondFraction < 1_000_000_000 else {
            throw Error.nanosecondOutOfRange(nanosecondFraction)
        }
        self.secondsSinceUnixEpoch = secondsSinceUnixEpoch
        self.nanosecondFraction = nanosecondFraction
    }
}

// MARK: - Error

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Instant {
    /// Errors that can occur when creating an Instant
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Nanosecond fraction must be 0-999,999,999
        case nanosecondOutOfRange(Int32)
    }
}

// MARK: - Unchecked Initialization

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Instant {
    /// Create an instant without validation (internal use only)
    ///
    /// - Warning: Only use when nanosecondFraction is known to be valid (0-999,999,999)
    internal init(unchecked secondsSinceUnixEpoch: Int64, nanosecondFraction: Int32) {
        self.secondsSinceUnixEpoch = secondsSinceUnixEpoch
        self.nanosecondFraction = nanosecondFraction
    }
}

// MARK: - Initialization

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Instant {

    /// Create instant from Time
    ///
    /// Transforms calendar representation to timeline representation.
    ///
    /// - Parameter time: The time to convert
    public init(_ time: Time) {
        self.secondsSinceUnixEpoch = Int64(time.secondsSinceEpoch)
        self.nanosecondFraction = Int32(time.totalNanoseconds)
    }
}

// MARK: - Comparable

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Instant {
    public static func < (lhs: Instant, rhs: Instant) -> Bool {
        if lhs.secondsSinceUnixEpoch == rhs.secondsSinceUnixEpoch {
            return lhs.nanosecondFraction < rhs.nanosecondFraction
        }
        return lhs.secondsSinceUnixEpoch < rhs.secondsSinceUnixEpoch
    }
}

// MARK: - Timeline Arithmetic

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Instant {
    /// Add a duration to an instant
    ///
    /// Timeline arithmetic - adds a fixed duration on the UTC timeline.
    ///
    /// Note: Duration has attosecond precision (10^-18), but Instant stores
    /// nanoseconds (10^-9). Sub-nanosecond precision is lost.
    ///
    /// - Parameters:
    ///   - lhs: The instant
    ///   - rhs: The duration to add
    /// - Returns: A new instant advanced by the duration
    public static func + (lhs: Instant, rhs: Duration) -> Instant {
        let (durationSeconds, attoseconds) = rhs.components

        // Convert attoseconds to nanoseconds (loses sub-nanosecond precision)
        // attoseconds / 10^9 = nanoseconds
        let nanosFromDuration = attoseconds / 1_000_000_000

        // Add seconds and nanoseconds separately
        var totalSeconds = lhs.secondsSinceUnixEpoch + durationSeconds
        var totalNanos = Int64(lhs.nanosecondFraction) + nanosFromDuration

        // Normalize: ensure nanos in range [0, 1_000_000_000)
        while totalNanos >= 1_000_000_000 {
            totalSeconds += 1
            totalNanos -= 1_000_000_000
        }
        while totalNanos < 0 {
            totalSeconds -= 1
            totalNanos += 1_000_000_000
        }

        return Instant(
            unchecked: totalSeconds,
            nanosecondFraction: Int32(totalNanos)
        )
    }

    /// Subtract a duration from an instant
    ///
    /// Note: Duration has attosecond precision (10^-18), but Instant stores
    /// nanoseconds (10^-9). Sub-nanosecond precision is lost.
    ///
    /// - Parameters:
    ///   - lhs: The instant
    ///   - rhs: The duration to subtract
    /// - Returns: A new instant moved back by the duration
    public static func - (lhs: Instant, rhs: Duration) -> Instant {
        let (durationSeconds, attoseconds) = rhs.components

        // Convert attoseconds to nanoseconds (loses sub-nanosecond precision)
        let nanosFromDuration = attoseconds / 1_000_000_000

        // Subtract seconds and nanoseconds separately
        var totalSeconds = lhs.secondsSinceUnixEpoch - durationSeconds
        var totalNanos = Int64(lhs.nanosecondFraction) - nanosFromDuration

        // Normalize: ensure nanos in range [0, 1_000_000_000)
        while totalNanos >= 1_000_000_000 {
            totalSeconds += 1
            totalNanos -= 1_000_000_000
        }
        while totalNanos < 0 {
            totalSeconds -= 1
            totalNanos += 1_000_000_000
        }

        return Instant(
            unchecked: totalSeconds,
            nanosecondFraction: Int32(totalNanos)
        )
    }

    /// Calculate duration between two instants
    ///
    /// - Parameters:
    ///   - lhs: The later instant
    ///   - rhs: The earlier instant
    /// - Returns: Duration from rhs to lhs (positive if lhs > rhs)
    public static func - (lhs: Instant, rhs: Instant) -> Duration {
        let secondsDiff = lhs.secondsSinceUnixEpoch - rhs.secondsSinceUnixEpoch
        let nanosDiff = lhs.nanosecondFraction - rhs.nanosecondFraction

        return Duration.seconds(secondsDiff) + Duration.nanoseconds(Int64(nanosDiff))
    }
}

// MARK: - InstantProtocol Conformance

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Instant: InstantProtocol {
    public typealias Duration = Swift.Duration

    public func advanced(by duration: Duration) -> Instant {
        self + duration
    }

    public func duration(to other: Instant) -> Duration {
        other - self
    }
}
