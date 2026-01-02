//
//  Parsing.String+Parser.swift
//  swift-standards
//
//  String conformance to Parser and Printer for literal usage.
//

extension String: Parsing.Parser {
    public typealias Input = Substring
    public typealias Output = Void

    @inlinable
    public func parse(_ input: inout Substring) throws(Parsing.Error) {
        guard input.hasPrefix(self) else {
            throw Parsing.Error.unexpected(String(input.prefix(self.count)), expected: self)
        }
        input = input.dropFirst(self.count)
    }
}

extension String: Parsing.Printer {
    @inlinable
    public func print(_ output: Void, into input: inout Substring) throws(Parsing.Error) {
        input.insert(contentsOf: self, at: input.startIndex)
    }
}
