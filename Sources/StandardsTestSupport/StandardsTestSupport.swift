// Namespace.swift
// StandardsTestSupport
//
// Public namespace for StandardsTestSupport APIs

import Foundation

/// Namespace for StandardsTestSupport performance testing utilities
///
/// Provides measurement, formatting, and assertion functions for performance testing.
///
/// Example:
/// ```swift
/// let (result, measurement) = StandardsTestSupport.measure {
///     numbers.sum()
/// }
/// StandardsTestSupport.printPerformance("sum", measurement)
/// ```
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public enum StandardsTestSupport {}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension StandardsTestSupport {
    /// Namespace for performance-related types
    public enum Performance {}
}
