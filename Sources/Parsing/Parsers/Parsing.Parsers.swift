//
//  Parsing.Parsers.swift
//  swift-standards
//
//  Namespace for built-in parser types.
//

extension Parsing {
    /// Namespace for built-in parser implementations.
    ///
    /// This namespace contains all the concrete parser types used internally
    /// by combinators and result builders. Users typically don't construct
    /// these directly - they're returned by combinator methods.
    ///
    /// ## Categories
    ///
    /// - **Transforming**: `Map`, `TryMap`, `FlatMap`, `Filter`
    /// - **Combining**: `Take2`, `Take3`, etc. (sequential composition)
    /// - **Branching**: `OneOf`, `Optional`
    /// - **Repeating**: `Many`, `AtLeast`, `Exactly`
    /// - **Primitives**: `Literal`, `Prefix`, `First`, `Rest`
    /// - **Control Flow**: `Lazy`, `Not`, `Peek`
    public enum Parsers {}
}
