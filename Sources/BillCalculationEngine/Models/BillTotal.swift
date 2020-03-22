//
//  BillTotal.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import Foundation

public struct BillTotal {

    let tax: Amount
    let total: Amount
    let appliedDiscount: [Discount]
    let discountedAmount: Amount
}
