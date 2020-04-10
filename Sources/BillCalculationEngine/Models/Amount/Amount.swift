//
//  Amount.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

/// The amount object for the BillCalculationEngine.
///
/// Currency is built into the Amount struct, to all kind of mathematic operations can only be performed between amount with the same currency.
/// When different currency is detected, corresponding errors/exceptions will be thrown.
public struct Amount: Codable {

    static private let currencyFractionDigits = 2

    /// The currency of Amount.
    public let currency: String?

    /// The value of the Amount.
    ///
    /// The default value is 0.
    public var value: Decimal {

        if let valueInDecimal = self.valueInDecimal {
            return valueInDecimal
        }
        let fromString = Decimal(string: valueInString ?? "0")
        return fromString ?? 0
    }

    /// The value of the Amount in String,
    /// which is used when the object is decoded from JSON.
    internal var valueInString: String?

    /// The value of the Amount in Decimal,
    /// which is used when the object is initialized using the initializer.
    internal var valueInDecimal: Decimal?

    public init(currency: String?, value: Decimal?) {
        self.currency = currency
        self.valueInDecimal = value
        self.valueInString = nil
    }

    enum CodingKeys: String, CodingKey {
        case currency
        case valueInString = "value"
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
    ///   - left: An Amount object to compare.
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
    
    /// A zero amount object, with nil as its currency.
    public static var zero: Amount {

        return Amount(currency: nil, value: 0)
    }
    
    /// Addition operator.
    /// - Parameters:
    ///   - left: An Amount object to add.
    ///   - right: Another Amount object to add.
    /// - Throws: If the left and right operands doesn't share the same currency,
    /// an `incompatibleAmountCurrency` will be thrown.
    /// - Returns: The sum of the two Amount objects.
    public static func + (left: Amount, right: Amount) throws -> Amount  {

        if left.currency == nil &&
            right.currency == nil &&
            left.value == 0 &&
            right.value == 0 {
            return .zero
        }

        guard let currency = self.shareSameCurrency(between: left, and: right) else {
            throw AmountCalculationError.incompatibleAmountCurrency
        }

        return Amount(currency: currency, value: left.value + right.value)
    }

    /// Addition assignment operator.
    /// - Parameters:
    ///   - left: The Amount object to add on.
    ///   - right: The Amount object be added.
    /// - Throws: If the left and right operands doesn't share the same currency,
    /// an `incompatibleAmountCurrency` will be thrown.
    public static func += (left: inout Amount, right: Amount) throws {

        if left.currency == nil &&
            right.currency == nil &&
            left.value == 0 &&
            right.value == 0 {
            return
        }

        guard let currency = self.shareSameCurrency(between: left, and: right) else {
            throw AmountCalculationError.incompatibleAmountCurrency
        }

        left = Amount(currency: currency, value: left.value + right.value)
    }

    /// Subtraction operator.
    /// - Parameters:
    ///   - left: The minuend Amount object.
    ///   - right: The subtrahend Amount object.
    /// - Throws: If the left and right operands doesn't share the same currency,
    /// an `incompatibleAmountCurrency` will be thrown.
    /// - Returns: The difference between of the two Amount objects.
    public static func - (left: Amount, right: Amount) throws -> Amount  {

        if left.currency == nil &&
            right.currency == nil &&
            left.value == 0 &&
            right.value == 0 {
            return .zero
        }

        guard let currency = self.shareSameCurrency(between: left, and: right) else {
            throw AmountCalculationError.incompatibleAmountCurrency
        }

        return Amount(currency: currency, value: left.value - right.value)
    }

    /// Subtraction assignment c.
    /// - Parameters:
    ///   - left: The minuend Amount object.
    ///   - right: The subtrahend Amount object.
    /// - Throws: If the left and right operands doesn't share the same currency,
    /// an `incompatibleAmountCurrency` will be thrown.
    public static func -= (left: inout Amount, right: Amount) throws {
        
        if left.currency == nil &&
            right.currency == nil &&
            left.value == 0 &&
            right.value == 0 {
            return
        }

        guard let currency = self.shareSameCurrency(between: left, and: right) else {
            throw AmountCalculationError.incompatibleAmountCurrency
        }

        left = Amount(currency: currency, value: left.value - right.value)
    }
    
    /// Multiplication multiplication.
    /// - Parameters:
    ///   - amount: The Amount object to be multiplied.
    ///   - multiplier: The multiplier.
    /// - Returns: The amount of product the input amount and multiplier.
    ///
    /// The type of the multiplier is Double. This is because this method is meant to be used for
    /// calculating the amount of tax or the discounted amount of a percentage discount.
    public static func * (amount: Amount, multiplier: Double) -> Amount {
    
        let twoDigitFractionHandler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.plain,
                                                             scale: Int16(Self.currencyFractionDigits),
                                                             raiseOnExactness: false,
                                                             raiseOnOverflow: false,
                                                             raiseOnUnderflow: false,
                                                             raiseOnDivideByZero: false)

        let multiplierDecimal = NSDecimalNumber(value: multiplier)
        let result = (amount.value as NSDecimalNumber).multiplying(by: multiplierDecimal, withBehavior: twoDigitFractionHandler)
        return Amount(currency: amount.currency, value: result as Decimal)
    }

    
    /// Division operator
    /// - Parameters:
    ///   - amount: The Amount object to be divided.
    ///   - divisor: The divisor.
    /// - Returns: The amount of the quotien betwen the input amount and divisor.
    ///
    /// The type of the divisor is Int. This is because this method is meant to be used for dividing an amount
    /// into several equal parts, such as calculating separat bill amount.
    ///
    /// Right now, this operator is not used by Bill Calculation Engine yet.
    public static func / (amount: Amount, divisor: Int) -> Amount {
        
        return amount * (1 / Double(divisor))
    }
}
