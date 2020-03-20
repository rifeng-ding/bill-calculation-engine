//
//  Discount.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

public struct Discount: Codable {

    /// Type of the discount
    public enum `Type`: String, Codable {
        /// The discount direclty reduce the
        case fixedAmount
        case percentage
    }

    public let type: `Type`
    public let amount: Amount?
    public let percentage: Double?
}
