//
//  Product.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

public struct Product: Codable {
    public let name: String
    public let category: ProductCategory
    public let price: Amount

    public func taxAmount(for taxes: [Tax]) -> Amount {

        var taxAmount = Amount.zero
        for tax in taxes {
            if let applicableCategories = tax.applicableCategories,
                !applicableCategories.contains(self.category) {
                continue
            }
            // since taxAmount is accumulation of the calculations' results, the force try here is safe.
            try! taxAmount += price.multiply(by: tax.percentage)
        }
        return taxAmount
    }
}
