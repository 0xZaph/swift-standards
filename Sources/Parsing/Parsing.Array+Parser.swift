//
//  Parsing.Array+Parser.swift
//  swift-standards
//
//  Array conformance to Parser and Printer for literal usage.
//

extension Array: Parsing.Parser where Element: Equatable {
    public typealias Input = ArraySlice<Element>
    public typealias Output = Void

    @inlinable
    public func parse(_ input: inout ArraySlice<Element>) throws(Parsing.Error) {
        for expected in self {
            guard let actual = input.first else {
                throw Parsing.Error.unexpectedEnd(expected: "\(expected)")
            }
            guard actual == expected else {
                throw Parsing.Error.unexpected(actual, expected: "\(expected)")
            }
            input = input.dropFirst()
        }
    }
}

extension Array: Parsing.Printer where Element: Equatable {
    @inlinable
    public func print(_ output: Void, into input: inout ArraySlice<Element>) throws(Parsing.Error) {
        input.insert(contentsOf: self, at: input.startIndex)
    }
}
