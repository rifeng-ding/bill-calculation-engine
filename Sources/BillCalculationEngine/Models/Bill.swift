//
//  BillTotal.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import Foundation

/// The bill object for the BillCalculationEngine.
public struct Bill {

    /// The sum of price of all products on the bill, exclude taxes and discounts.
    public let subtotal: Amount

    /// The sum all applicable taxes for all products on the bill.
    public let tax: Amount

    /// Discounts that has been applied on the bill, in the order of how they are applied.
    public let appliedDiscounts: [Discount]

    /// The sum of the discounted amount from all the applied discounts.
    public let discountedAmount: Amount

    /// The total of the bill, which is essentially subtotal + tax - discountedAmount.
    public let total: Amount
}
