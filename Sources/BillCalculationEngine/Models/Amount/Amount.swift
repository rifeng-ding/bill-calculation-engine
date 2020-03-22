//
//  Amount.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

public struct Amount: Codable {

    static private let currencyFractionDigits = 2

    /// The currency of Amount.
    public let currency: String?

    /// The value of the Amount.
    ///
    /// When the value is not included in the JSON payload, 0 is returned.
    public var value: Decimal {

        if let valueInDecimal = self.valueInDecimal {
            return valueInDecimal
        }
        let fromString = Decimal(string: valueInString ?? "0")
        return fromString ?? 0
    }

    /// The value of the Amount decoded from JSON.
    internal let valueInString: String?
    internal let valueInDecimal: Decimal?

    init(currency: String?, value: Decimal?) {
        self.currency = currency
        self.valueInDecimal = value
        self.valueInString = nil
    }

    enum codingKeys: String, CodingKey {
        case currency
        case _value = "value"
    }


    /// Returns the currency as a String, if the two Amount objects share the same currency.
    ///
    /// This method is used as the check to determine whehter it is safe to perform basic mathmatic operations
    /// (e.g. +, -, etc.) between two Amount objects. The fundamental idea is:
    /// if two Amount objects doesn't share the same currency, then they cannot be used
    /// for a mathmatic operations.
    ///
    /// When at least one object has non-zero value, the currency of the zero value object is ignored.
    ///
    /// When both objects have 0 as value:
    ///
    /// 1. If only one of the objects has non-nil currency, then this currency is returned.
    ///
    /// 2. If both objects has non-nil currency: if the currency are the same, the this curreny will be returned;
    /// otherwise, nil is returned.
    ///
    /// 3. If both objects has nil as currency, nil is returned.
    ///
    /// - Parameters:
    ///   - left: An Amount object to compare
    ///   - right: Another Amount object to compare.
    public static func shareSameCurrency(between left: Amount, and right: Amount)-> String? {

        if let leftCurrency = left.currency,
            let rightCurrency = right.currency {

            return leftCurrency == rightCurrency ? leftCurrency : nil
        }

        // then at least one of the Amount has nil as currency
        let nilCurrencyAmount = left.currency == nil ? left : right
        let nonNilCurrencyAmount = left.currency == nil ? right : left
        guard nilCurrencyAmount.value == 0 else {
            return nil
        }
        return nonNilCurrencyAmount.currency
    }

    public static var zero: Amount {

        return Amount(currency: nil, value: 0)
    }

    public static func + (left: Amount, right: Amount) throws -> Amount  {

        guard let currency = self.shareSameCurrency(between: left, and: right) else {
            throw AmountCalculationError.incompatibleAmountCurrency
        }

        return Amount(currency: currency, value: left.value + right.value)
    }

    public static func += (left: inout Amount, right: Amount) throws {

        guard let currency = self.shareSameCurrency(between: left, and: right) else {
            throw AmountCalculationError.incompatibleAmountCurrency
        }

        left = Amount(currency: currency, value: left.value + right.value)
    }

    public static func - (left: Amount, right: Amount) throws -> Amount  {

        guard let currency = self.shareSameCurrency(between: left, and: right) else {
            throw AmountCalculationError.incompatibleAmountCurrency
        }

        return Amount(currency: currency, value: left.value - right.value)
    }

    public static func -= (left: inout Amount, right: Amount) throws {

        guard let currency = self.shareSameCurrency(between: left, and: right) else {
            throw AmountCalculationError.incompatibleAmountCurrency
        }

        left = Amount(currency: currency, value: left.value - right.value)
    }

    public func multiply(by multiplier: Double) -> Amount {

        let twoDigitFractionHandler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.plain,
                                                             scale: Int16(Self.currencyFractionDigits),
                                                             raiseOnExactness: false,
                                                             raiseOnOverflow: false,
                                                             raiseOnUnderflow: false,
                                                             raiseOnDivideByZero: false)

        let multiplierDecimal = NSDecimalNumber(value: multiplier)
        let result = (self.value as NSDecimalNumber).multiplying(by: multiplierDecimal, withBehavior: twoDigitFractionHandler)
        return Amount(currency: self.currency, value: result as Decimal)
    }

    public func divide(by divisor: Int) -> Amount {
        
        return self.multiply(by: 1 / Double(divisor))
    }
}
