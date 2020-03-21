//
//  Identifiable.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import Foundation

/// Provide a general way mark an object to be identifiable.
public protocol Identifiable: Equatable {

    var identifier: String { get }
}

public extension Identifiable {

    /// Returns a Boolean value indicating whether objcts shared the same identifer.
    ///
    /// When true is returned, it only means the identifiers of both obejects are the same.
    /// However, it doesn't mean that all properties of the two objects are all the same.
    /// - Parameters:
    ///   - lhs: One object.
    ///   - rhs: Anonther object.
    static func == (lhs: Self, rhs: Self) -> Bool {

        return lhs.identifier == rhs.identifier
    }
}
