//
//  ProcductCategory.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

/// The supported product categories.
///
/// Since `ProductCategory` conforms to `CaseDefault`
/// with `defaultCase` set to `unknown`,
/// during decoding, any unmatched raw value, will ends up as `unknown`.
public enum ProductCategory: String, CaseDefaultCodable{

    public static var defaultCase: ProductCategory = .unknown

    /// Unknown type. During decoding, any unmatched raw value, will ends up as `unknown`.
    case unknown
    
    /// Product type for appetizers.
    case appetizers
    
    /// Product type for mains.
    case mains
    
    /// Product type for drinks.
    case drinks
    
    /// Product type for alchol.
    case alcohol

    enum Key: CodingKey {
        case appetizers
        case mains
        case drinks
        case alcohol
        case unknown
    }
}
