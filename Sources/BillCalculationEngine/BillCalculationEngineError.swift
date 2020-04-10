//
//  BillCalculationEngineErrror.swift
//  
//
//  Created by Rifeng Ding on 2020-03-19.
//

import Foundation

/// Errors that could happen during the bill generation.
public enum BillCalculationEngineErrror: Error {

    /// The input products doesn't have the same currency
    case inconsisentCurrencyAmongProducts

    /// Try to apply a fixed-value discount that doesn't have the same currency to the total.
    case invalidDiscountCurrency
}
