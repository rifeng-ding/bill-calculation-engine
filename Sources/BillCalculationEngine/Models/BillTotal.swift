//
//  BillTotal.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import Foundation

public struct BillTotal {

    public let tax: Amount
    public let total: Amount
    public let appliedDiscount: [Discount]
    public let discountedAmount: Amount
}
