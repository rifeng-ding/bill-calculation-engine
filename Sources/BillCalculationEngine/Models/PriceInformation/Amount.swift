//
//  Amount.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

// TODO: handle Currency

public struct Amount: Codable {

    static private let currencyFractionDigits = 2

    /// The currency of Amount.
    public let currency: String?
    
    /// The value of the Amount.
    public let value: Decimal

    /// Returns the currency as a String, if the two Amount object share the same currency.
    ///
    /// The currency of Amount that has 0 value is ignored.
    /// When values of both object are 0, this method return the non-nil curreny, if there's any.
    /// - Parameters:
    ///   - left: An Amount object to compare
    ///   - right: Another Amount object to compare.
    public static func shareSameCurrency(between left: Amount, and right: Amount)-> String? {
        let hasSameCurrency = left.currency == right.currency
        let atLeastOneIsZero = left == .zero || right == .zero

        guard hasSameCurrency || atLeastOneIsZero else {
            return nil
        }

        return left.currency ?? right.currency
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

        left = Amount(currency: currency, value: left.value - right.value)
    }

    public static func - (left: Amount, right: Amount) throws -> Amount  {

        guard let currency = self.shareSameCurrency(between: left, and: right) else {
            throw AmountCalculationError.incompatibleAmountCurrency
        }

        return Amount(currency: currency, value: left.value + right.value)
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

