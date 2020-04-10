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

/// The discount object for the BillCalculationEngine.
public class Discount: Codable, Identifiable {

    /// Type of the discount
    ///
    /// Since `Discount.Type` conforms to `CaseDefault`
    /// with `defaultCase` set to `unknown`,
    /// during decoding, any unmatched raw value, will ends up as `unknown`.
    public enum `Type`: String, CaseDefaultCodable {

        public static var defaultCase: Discount.`Type` = .unknown

        /// Unknown type. During decoding, any unmatched raw value, will ends up as `unknown`.
        case unknown
        /// The discount type that  direclty reduces the subtotal by a fixed amount.
        case fixedAmount
        /// The discount type that redueces the subtotal by a given percentage.
        case percentage
    }
    
    /// The identifier of the discount.
    ///
    /// The default value is "" (empty string).
    public var identifier: String {
        return self._identifier ?? ""
    }
    internal let _identifier: String?

    /// The type of the discount.
    public let type: `Type`
    
    /// The amount of the discount.
    ///
    /// If the type of the discount is `percentage`, this property is always nil.
    public let amount: Amount?
    
    /// The percenate of the discount.
    ///
    /// If the type of the discount is `fixedAmount`, this property is always nil.
    public let percentage: Double?

    enum CodingKeys: String, CodingKey {
        case _identifier = "identifier"
        case type
        case amount
        case percentage
    }

    /// A boolean value indicating whether the discount is valid.
    ///
    /// When a discount is being applied through apply(onAmount:),
    /// this value is checked and only valid discount will be applied.
    ///
    /// For example, percentage discount with its `percentage > 1` is considered as invalid.
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
    /// This initializer in interal, and it's mainly for unit test.
    /// - Parameters:
    ///   - type: the type of the discount
    ///   - amount: the amount of the discount
    ///   - percentage: the percentage of the discount
    internal init(identifier: String?, type: `Type`, amount: Amount? = nil, percentage: Double? = nil) {

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

        self._identifier = identifier
        self.type = .percentage
        self.percentage = anyPercentage
        self.amount =  nil
    }

    /// Initialize a fixed amount discount with any amount value.
    ///
    /// This initializer doesn't perform any check on the amount value,
    /// e.g. it even can be a negative amount.
    ///
    /// This initialzer is for unit test purpose.
    /// - Parameter anyPercentage: any fixed amount for the discount
    internal init(identifier: String, anyFixedAmount: Amount?) {

        self._identifier = identifier
        self.type = .fixedAmount
        self.percentage = nil
        self.amount =  anyFixedAmount
    }

    /// A convenient way to get an unknown type discount.
    ///
    /// This property is for unit test purpose.
    internal static var unknown: Discount {

        return Discount(identifier:"", type: .unknown)
    }

    // MARK: - Interanl Methods
    // This method is marked as internal, becuase apply discount needs business logic. So it's only exposed
    // through BillCalculationEngine's bill(for: withTaxes: taxes: discounts:), which contains the business logic.
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
            let discountedAmount = originalAmount * percentage
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
