//
//  Product.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

public struct Product: Codable, Identifiable {

    public var identifier: String {
        return self._identifier ?? ""
    }
    internal var _identifier: String?

    public let name: String?
    public let category: ProductCategory

    public var price: Amount {
        return self._price ?? .zero
    }
    internal var _price: Amount?

    public var isTaxExempt: Bool {
        return self._isTaxExempt ?? false
    }
    public let _isTaxExempt: Bool?

    enum codingKeys: String, CodingKey {
        case _identifier = "identifier"
        case name
        case category
        case _price = "price"
        case _isTaxExempt = "isTaxExempt"
    }

    init(identifier: String?,
         name: String?,
         category: ProductCategory,
         price: Amount?,
         isTaxExempt: Bool?) {

        self._identifier = identifier
        self.name = name
        self.category = category
        self._price = price
        self._isTaxExempt = isTaxExempt
    }

    public func taxAmount(for taxes: [Tax]) -> Amount {

        guard !self.isTaxExempt else {
            return Amount(currency: self.price.currency, value: 0)
        }

        var taxAmount = Amount.zero
        for tax in taxes where tax.isEnabled {
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
