//
//  Discount.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

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

    public var identifier: String {
        return self._identifier ?? ""
    }
    internal let _identifier: String?

    public let type: `Type`
    public let amount: Amount?
    public let percentage: Double?

    enum CodingKeys: String, CodingKey {
        case _identifier = "identifier"
        case type
        case amount
        case percentage
    }

    public var isValid: Bool {

        switch self.type {
        case .fixedAmount:
            guard let amount = self.amount else {
                return false
            }
            return amount > .zero
        case .percentage:
            guard let percentage = self.percentage else {
                return false
            }
            return percentage > 0 && percentage <= 1
        case .unknown:
            return false
        }
    }

    public init(identifier: String, fixedAmount: Amount) {

        self._identifier = identifier
        self.type = .fixedAmount
        self.amount = fixedAmount > .zero ? fixedAmount : Amount(currency: fixedAmount.currency, value: 0)
        self.percentage = nil
    }

    public init(identifier: String, percentage: Double) {

        self._identifier = identifier
        self.type = .percentage
        self.percentage = (percentage > 0 && percentage <= 1) ? percentage : 1
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

        self._identifier = identifier
        self.type = type
        self.percentage = percentage
        self.amount =  amount
    }


    /// Initialize a percentage discount with any percentage value.
    ///
    /// This initializer doesn't perform any check on the percentage value,
    /// e.g. it even can be bigger than 1 or smaller than 0.
    ///
    /// This initialzer is for unit test purpose.
    /// - Parameter anyPercentage: any percentage for the discount
    internal init(identifier: String, anyPercentage: Double?) {

        self = Discount(identifier: identifier, type: .percentage, amount: nil, percentage: anyPercentage)
    }

    /// Initialize a fixed amount discount with any amount value.
    ///
    /// This initializer doesn't perform any check on the amount value,
    /// e.g. it even can be a negative amount.
    ///
    /// This initialzer is for unit test purpose.
    /// - Parameter anyPercentage: any fixed amount for the discount
    internal init(identifier: String, anyFixedAmount: Amount?) {

        self = Discount(identifier: identifier, type: .fixedAmount, amount: anyFixedAmount, percentage: nil)
    }

    /// A convenient way to get an unknown type discount.
    ///
    /// This property is for unit test purpose.
    internal static var unknown: Discount {

        return Discount(identifier:"", type: .unknown)
    }

    // MARK: - Interanl Methods
    // This method is marked as internal, becuase apply discount needs business logic. So it's only exposed
    // through BillCalculationEngine's total(for: withTaxes: taxes: discounts:), which contains the business logic.
    internal func apply(onAmount originalAmount: Amount) throws -> DiscountApplyingResult {

        let defaultResult = DiscountApplyingResult(discountedAmount: .zero,
                                                   newSubtotal: originalAmount)
        switch self.type {
        case .unknown:
            return defaultResult
            
        case .fixedAmount:
            guard let discountAmount = self.amount, self.isValid else {
                return defaultResult
            }
            guard let currency = Amount.shareSameCurrency(between: originalAmount, and: discountAmount) else {
                throw BillCalculationEngineErrror.invalidDiscountCurrency
            }
            // Since the above guard already checked the currency, here the force try is safe
            let newSubtotal = originalAmount >= discountAmount ? (try! originalAmount - discountAmount) : Amount(currency: currency, value: 0)
            let discountedAmount = originalAmount >= discountAmount ? discountAmount : originalAmount
            return DiscountApplyingResult(discountedAmount: discountedAmount,
                                          newSubtotal: newSubtotal)

        case .percentage:
            guard let percentage = self.percentage, self.isValid else {
                return defaultResult
            }
            let discountedAmount = originalAmount.multiply(by: percentage)
            guard discountedAmount != .zero else {
                // Since 0 < percentage < 1, if discountedAmount == 0,
                // the only reason is subtotal is too small,
                // e.g. subtotal = 0.01, discount = 0.25,
                // 0.01 * 0.25 = 0.0025 ≈ 0
                return DiscountApplyingResult(discountedAmount: originalAmount,
                                              newSubtotal: Amount(currency: originalAmount.currency, value: 0))
            }
            // since the discountedAmount is derived from the subtotal, the force try is safe
            let newSubtotal = try! originalAmount - discountedAmount
            return DiscountApplyingResult(discountedAmount: discountedAmount,
                                          newSubtotal: newSubtotal)
        }
    }
}
