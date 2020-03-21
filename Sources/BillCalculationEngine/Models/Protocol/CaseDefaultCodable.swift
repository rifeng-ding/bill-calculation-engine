//
//  CaseDefault.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import Foundation

/// Provides a way of assigning a default value to an enum
/// via a non-failable initializer and decoder implementation.
///
/// With the included default implemntations, Codable enum will
/// fallback to the provided `defaultCase`, when the raw value in the JSON
/// is not equal to any case's raw value.
public protocol CaseDefaultCodable: RawRepresentable, Codable where RawValue: Codable & Equatable {

    /// The case of the enum that should be considered "default"
    static var defaultCase: Self { get }
}

public extension CaseDefaultCodable {

    /// Returns an initialized enum case or the specified default value.
    ///
    /// - Parameters:
    ///   - rawValue: the rawValue of the initialized enum
    ///   - default: if the rawValue does not produce an enum, this value is initialized instead
    init(rawValue: RawValue, default: Self = defaultCase) {

        self = Self(rawValue: rawValue) ?? `default`
        if self == `default` {
            print("Unknown enum case `\(rawValue)` for type `\(type(of: self))`. Assigned default case value `\(self)`.")
        }
    }

    /// Decoder that calls the intializer with default value
    init(from decoder: Decoder) throws {

        let rawValue = try decoder.singleValueContainer().decode(RawValue.self)
        self = Self(rawValue: rawValue)
    }
}
