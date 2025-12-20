// TestSpacing.swift
// Shared test types for Layout tests

import Geometry
import Layout

/// A phantom type for testing Layout in a specific coordinate space
enum TestSpace {}

/// Type aliases for convenient test usage
typealias TestLayout = Layout<Double, TestSpace>
typealias TestGeometry = Geometry<Double, TestSpace>
