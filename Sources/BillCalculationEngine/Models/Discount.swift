//
//  Discount.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

// TODO: needs to be public or internal?
internal struct DiscountApplyingResult {

    let discountedAmount: Amount
    let newSubtotal: Amount
}

public struct Discount: Codable, Identifiable {

    /// Type of the discount
    public enum `Type`: String, CaseDefaultCodable {

        public static var defaultCase: Discount.`Type` = .unknown

        case unknown
        /// The discount direclty reduce the subtotal by a fixed amount.
        case fixedAmount
        /// The discount reduece the subtotal by a given percentage.
        case percentage
    }

    public let identifier: String
    public let type: `Type`
    public let amount: Amount?
    public let percentage: Double?

    public init(identifier: String, fixedAmount: Amount) {

        self.identifier = identifier
        self.type = .fixedAmount
        self.amount = fixedAmount > .zero ? fixedAmount : Amount(currency: fixedAmount.currency, value: 0)
        self.percentage = nil
    }

    public init(identifier: String, percentage: Double) {

        self.identifier = identifier
        self.type = .percentage
        self.percentage = (percentage > 0 && percentage < 1) ? percentage : 1
        self.amount = nil
    }


    /// Initialize a Discount object with all properties configable.
    ///
    /// This initializer in private, and it's mainly for unit test usage.
    /// - Parameters:
    ///   - type: the type of the discount
    ///   - amount: the amount of the discount
    ///   - percentage: the percentage of the discount
    private init(identifier: String, type: `Type`, amount: Amount? = nil, percentage: Double? = nil) {

        self.identifier = identifier
        self.type = type
        self.percentage = percentage
        self.amount =  amount
    }


    /// Initialize an percentage discount with any percentage value.
    ///
    /// This initializer doesn't perform any check on the value percentage,
    /// e.g. it even can be bigger than 1 or smaller than 0.
    ///
    /// This initialzer is for unit test purpose.
    /// - Parameter anyPercentage: any percentage for the discount
    internal init(identifier: String, withAnyPercentage anyPercentage: Double) {

        self = Discount(identifier: identifier, type: .percentage, amount: nil, percentage: anyPercentage)
    }

    /// A convenient way to get an unknown type discount.
    ///
    /// This property is for unit test purpose.
    internal static var unknown: Discount {

        return Discount(identifier:"", type: .unknown)
    }

    // MARK: - Interanl Methods
    // TODO: internal method throw public error seems a bit odd
    internal func apply(onSubtotal subtotal: Amount) throws -> DiscountApplyingResult {

        let defaultResult = DiscountApplyingResult(discountedAmount: .zero,
                                                   newSubtotal: subtotal)
        switch self.type {
        case .unknown:
            return defaultResult
            
        case .fixedAmount:
            guard let discountAmount = self.amount, discountAmount > .zero else {
                return defaultResult
            }
            guard let currency = Amount.shareSameCurrency(between: subtotal, and: discountAmount) else {
                throw BillCalculationEngineErrror.invalidDiscountCurrency
            }
            // Since the above guard already checked the currency, here the force try is safe
            let newSubtotal = subtotal >= discountAmount ? (try! subtotal - discountAmount) : Amount(currency: currency, value: 0)
            let discountedAmount = subtotal >= discountAmount ? discountAmount : subtotal
            return DiscountApplyingResult(discountedAmount: discountedAmount,
                                          newSubtotal: newSubtotal)

        case .percentage:
            guard let percentage = self.percentage, percentage > 0 && percentage < 1 else {
                return defaultResult
            }
            let discountedAmount = subtotal.multiply(by: percentage)
            guard discountedAmount != .zero else {
                // Since 0 < percentage < 1, if discountedAmount == 0,
                // the only reason is subtotal is too small,
                // e.g. subtotal = 0.01, discount = 0.25,
                // 0.01 * 0.25 = 0.0025 ≈ 0
                return DiscountApplyingResult(discountedAmount: subtotal,
                                              newSubtotal: Amount(currency: subtotal.currency, value: 0))
            }
            // since the discountedAmount is derived from the subtotal, the force try is safe
            let newSubtotal = try! subtotal - discountedAmount
            return DiscountApplyingResult(discountedAmount: discountedAmount,
                                          newSubtotal: newSubtotal)
        }
    }
}
