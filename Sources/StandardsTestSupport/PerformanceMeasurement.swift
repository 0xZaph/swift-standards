// PerformanceMeasurement.swift
// StandardsTestSupport
//
// Performance measurement primitives for Swift Testing

import Foundation
import Standards

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension StandardsTestSupport.Performance {
    /// Result of a performance measurement
    public struct Measurement: Sendable {
        /// All measured durations
        public let durations: [Duration]

        /// Minimum duration
        public var min: Duration {
            durations.min() ?? .zero
        }

        /// Maximum duration
        public var max: Duration {
            durations.max() ?? .zero
        }

        /// Median duration (50th percentile)
        public var median: Duration {
            percentile(0.5)
        }

        /// Average (mean) duration
        public var mean: Duration {
            guard !durations.isEmpty else { return .zero }
            let total = durations.reduce(Duration.zero, +)
            return total / durations.count
        }

        /// 95th percentile duration
        public var p95: Duration {
            percentile(0.95)
        }

        /// 99th percentile duration
        public var p99: Duration {
            percentile(0.99)
        }

        /// Calculate percentile
        public func percentile(_ p: Double) -> Duration {
            guard !durations.isEmpty else { return .zero }
            let sorted = durations.sorted()
            let index = Int(Double(sorted.count) * p)
            let clampedIndex = Swift.min(index, sorted.count - 1)
            return sorted[clampedIndex]
        }

        /// Standard deviation
        public var standardDeviation: Duration {
            guard durations.count > 1 else { return .zero }
            let meanSeconds = mean.inSeconds
            let variance = durations.reduce(0.0) { acc, duration in
                let diff = duration.inSeconds - meanSeconds
                return acc + (diff * diff)
            } / Double(durations.count - 1)
            return .seconds(sqrt(variance))
        }
    }
}

// MARK: - Measurement API

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension StandardsTestSupport {
    /// Measure performance of an operation
    ///
    /// Runs the operation multiple times with optional warmup iterations,
    /// collecting timing data for statistical analysis.
    ///
    /// Example:
    /// ```swift
    /// let measurement = StandardsTestSupport.measure(warmup: 3, iterations: 100) {
    ///     numbers.sum()
    /// }
    /// print("Median: \(StandardsTestSupport.formatDuration(measurement.median))")
    /// ```
    @discardableResult
    public static func measure<T>(
        warmup: Int = 0,
        iterations: Int = 10,
        operation: () -> T
    ) -> (result: T, measurement: Performance.Measurement) {
        // Warmup
        for _ in 0..<warmup {
            _ = operation()
        }

        // Measure
        var durations: [Duration] = []
        durations.reserveCapacity(iterations)
        var lastResult: T!

        for _ in 0..<iterations {
            let start = ContinuousClock.now
            lastResult = operation()
            let end = ContinuousClock.now
            durations.append(end - start)
        }

        return (lastResult, Performance.Measurement(durations: durations))
    }

    /// Measure performance of an async operation
    @discardableResult
    public static func measure<T>(
        warmup: Int = 0,
        iterations: Int = 10,
        operation: () async throws -> T
    ) async rethrows -> (result: T, measurement: Performance.Measurement) {
        // Warmup
        for _ in 0..<warmup {
            _ = try await operation()
        }

        // Measure
        var durations: [Duration] = []
        durations.reserveCapacity(iterations)
        var lastResult: T!

        for _ in 0..<iterations {
            let start = ContinuousClock.now
            lastResult = try await operation()
            let end = ContinuousClock.now
            durations.append(end - start)
        }

        return (lastResult, Performance.Measurement(durations: durations))
    }

    /// Single-shot timing measurement
    ///
    /// Times a single execution without statistical analysis.
    /// Useful for quick timing checks or when operations are too expensive to repeat.
    ///
    /// Example:
    /// ```swift
    /// let (result, duration) = StandardsTestSupport.time {
    ///     expensiveComputation()
    /// }
    /// ```
    @discardableResult
    public static func time<T>(operation: () -> T) -> (result: T, duration: Duration) {
        let start = ContinuousClock.now
        let result = operation()
        let end = ContinuousClock.now
        return (result, end - start)
    }

    /// Single-shot timing measurement for async operations
    @discardableResult
    public static func time<T>(operation: () async throws -> T) async rethrows -> (result: T, duration: Duration) {
        let start = ContinuousClock.now
        let result = try await operation()
        let end = ContinuousClock.now
        return (result, end - start)
    }
}

// MARK: - Duration Formatting

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension StandardsTestSupport.Performance {
    /// Format options for duration display
    public enum Format {
        case auto
        case nanoseconds
        case microseconds
        case milliseconds
        case seconds

        func format(_ duration: Duration) -> String {
            switch self {
            case .auto:
                let seconds = duration.inSeconds
                if seconds < 0.000001 {
                    return String(format: "%.2fns", duration.inNanoseconds)
                } else if seconds < 0.001 {
                    return String(format: "%.2fµs", duration.inMicroseconds)
                } else if seconds < 1.0 {
                    return String(format: "%.2fms", duration.inMilliseconds)
                } else {
                    return String(format: "%.2fs", seconds)
                }
            case .nanoseconds:
                return String(format: "%.2fns", duration.inNanoseconds)
            case .microseconds:
                return String(format: "%.2fµs", duration.inMicroseconds)
            case .milliseconds:
                return String(format: "%.2fms", duration.inMilliseconds)
            case .seconds:
                return String(format: "%.2fs", duration.inSeconds)
            }
        }
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension StandardsTestSupport {
    /// Format a duration for performance display
    ///
    /// Automatically selects appropriate unit (ns, µs, ms, s).
    ///
    /// Example:
    /// ```swift
    /// let formatted = StandardsTestSupport.formatDuration(.milliseconds(5.82))
    /// // "5.82ms"
    /// ```
    public static func formatDuration(_ duration: Duration, _ format: Performance.Format = .auto) -> String {
        format.format(duration)
    }
}

// MARK: - Duration arithmetic

extension Duration {
    static func / (lhs: Duration, rhs: Int) -> Duration {
        let (seconds, attoseconds) = lhs.components
        let totalAttoseconds = (Int128(seconds) * 1_000_000_000_000_000_000) + Int128(attoseconds)
        let dividedAttoseconds = totalAttoseconds / Int128(rhs)
        let newSeconds = Int64(dividedAttoseconds / 1_000_000_000_000_000_000)
        let newAttoseconds = Int64(dividedAttoseconds % 1_000_000_000_000_000_000)
        return Duration(secondsComponent: newSeconds, attosecondsComponent: newAttoseconds)
    }
}
