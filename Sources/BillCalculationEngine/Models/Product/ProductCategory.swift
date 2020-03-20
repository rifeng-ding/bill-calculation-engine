//
//  ProcductCategory.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

public enum ProductCategory: String, Codable {

    case appetizers
    case mains
    case drinks
    case alcohol
    case unknown

    enum Key: CodingKey {
        case appetizers
        case mains
        case drinks
        case alcohol
        case unknown
    }

    public init(from decoder: Decoder) throws {

        let rawValue = try decoder.singleValueContainer().decode(String.self)
        switch rawValue {
        case Self.appetizers.rawValue:
            self = .appetizers
        case Self.mains.rawValue:
            self = .mains
        case Self.drinks.rawValue:
            self = .drinks
        case Self.alcohol.rawValue:
            self = .alcohol
        default:
            self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .appetizers:
            try container.encode(Self.appetizers.rawValue, forKey: .appetizers)
        case .mains:
            try container.encode(Self.mains.rawValue, forKey: .mains)
        case .drinks:
            try container.encode(Self.drinks.rawValue, forKey: .drinks)
        case .alcohol:
            try container.encode(Self.alcohol.rawValue, forKey: .alcohol)
        case .unknown:
            try container.encode(Self.unknown.rawValue, forKey: .unknown)
        }
    }
}
