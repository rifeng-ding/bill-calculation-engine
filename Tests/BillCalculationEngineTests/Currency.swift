//
//  Currency.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import Foundation

/// The currencies for unit testing the package.
///
/// Since Amount in BillCalculationEngine uses String as the type of its currency,
/// it can handle currency of any type, even virtual ones that doesn't exist in real world,
/// such as reward program currencies.
/// Thus, 2 types of currencies are defined to be used for unit testing.
enum Currency: String {
    case cad = "CAD"
    case usd = "USD"
}
