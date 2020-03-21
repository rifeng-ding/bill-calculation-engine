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

public struct Discount: Codable {

    /// Type of the discount
    public enum `Type`: String, Codable {
        /// The discount direclty reduce the
        case fixedAmount
        case percentage
    }

    public let type: `Type`
    public let amount: Amount?
    public let percentage: Double?

    public init(fixedAmount: Amount) {
        self.type = .fixedAmount
        self.amount = fixedAmount > .zero ? fixedAmount : Amount(currency: fixedAmount.currency, value: 0)
        self.percentage = nil
    }

    public init(percentage: Double) {
        self.type = .percentage
        self.percentage = percentage < 1 ? percentage : 1
        self.amount = nil
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

    }

    // MARK: - Interanl Methods
    // TODO: internal method throw public error seems a bit odd
    internal func apply(onSubtotal subtotal: Amount) throws -> DiscountApplyingResult {

        switch self.type {
        case .fixedAmount:
            guard let discountAmount = self.amount, discountAmount > .zero else {
                return DiscountApplyingResult(discountedAmount: .zero,
                                              newSubtotal: subtotal)
            }
            guard let currency = Amount.shareSameCurrency(between: subtotal, and: discountAmount) else {
                throw BillCalculationEngineErrror.invalidDiscountCurrency
            }
            // Since the above guard already checked the currency, here the force try is safe
            let newSubtotal = subtotal >= discountAmount ? (try! subtotal - discountAmount) : subtotal
            let discountedAmount = subtotal >= discountAmount ? discountAmount :  Amount(currency: currency, value: 0)
            return DiscountApplyingResult(discountedAmount: discountedAmount,
                                          newSubtotal: newSubtotal)

        case .percentage:
            guard let percentage = self.percentage, percentage > 0 && percentage < 1 else {
                return DiscountApplyingResult(discountedAmount: .zero,
                                              newSubtotal: subtotal)
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
