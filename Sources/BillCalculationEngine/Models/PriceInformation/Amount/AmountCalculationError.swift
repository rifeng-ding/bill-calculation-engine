//
//  File.swift
//  
//
//  Created by Rifeng Ding on 2020-03-19.
//

import Foundation

public enum AmountCalculationError: Error {
    /// Cannot perform calcuation between Amount objects that don't share the same currency, doesn't have currency at all.
    ///
    /// See the documentation in Amount for more details.
    case incompatibleAmountCurrency
}
