//
//  ProcductCategory.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

public enum ProductCategory: String, Codable, CaseDefault{

    public static var defaultCase: ProductCategory = .unknown

    case unknown
    case appetizers
    case mains
    case drinks
    case alcohol

    enum Key: CodingKey {
        case appetizers
        case mains
        case drinks
        case alcohol
        case unknown
    }
}
