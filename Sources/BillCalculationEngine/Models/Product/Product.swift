//
//  Product.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

/// The product object for the BillCalculationEngine.
public class Product: Codable, Identifiable {
    
    /// The identifer of the product.
    ///
    /// The default value is "" (empty string).
    public var identifier: String {
        return self._identifier ?? ""
    }
    internal let _identifier: String?
    
    /// The name of the product.
    public let name: String?
    
    /// The category of the product.
    public let category: ProductCategory

    /// The price of the product.
    ///
    /// The default value is a zero amount, with `nil` as currency.
    public var price: Amount {
        return self._price ?? .zero
    }
    internal let _price: Amount?

    /// A boolean value indicatiing whether the product should be exempted from taxes.
    ///
    /// the default value is `false`.
    public var isTaxExempt: Bool {
        get {
            return self._isTaxExempt ?? false
        }
        set {
            self._isTaxExempt = newValue
        }
    }
    internal var _isTaxExempt: Bool?

    enum CodingKeys: String, CodingKey {
        case _identifier = "identifier"
        case name
        case category
        case _price = "price"
        case _isTaxExempt = "isTaxExempt"
    }

    public init(identifier: String?,
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
    
    /// Calculate the amount of tax for given taxes.
    /// - Parameter taxes: Taxes to be applied on the product.
    /// - Returns: The amount of tax.
    ///
    /// If the product has `isTaxExempt == true`,
    /// then a zero amount with the product's price's currency is returned.
    ///
    /// Otherwise, the amount of tax is calcuated based on
    /// each input tax's `applicableCategories` and the product's category.
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
            try! taxAmount += price * tax.percentage
        }
        return taxAmount
    }
}
