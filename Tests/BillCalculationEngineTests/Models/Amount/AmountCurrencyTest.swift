//
//  AmountTest.swift
//  
//
//  Created by Rifeng Ding on 2020-03-20.
//

import XCTest
@testable
import BillCalculationEngine

final class AmountCurrencyTest: XCTestCase {

    let unimportantValue: Decimal = 5

    // MARK: - Test cases for non-zero value

    /// When both Amount objects has non-nil currency and non-zero as value
    func testNonNilCurrenciesWithNonZeroValues() {
        // Give
        let cadAmount0 = Amount(currency: Currency.cad.rawValue, value: self.unimportantValue)
        let cadAmount1 = Amount(currency: Currency.cad.rawValue, value:  self.unimportantValue)
        let usdAount = Amount(currency: Currency.usd.rawValue, value:  self.unimportantValue)

        // When
        let shareCurrency = Amount.shareSameCurrency(between: cadAmount0, and: cadAmount1)
        let notShareCurrency = Amount.shareSameCurrency(between: cadAmount0, and: usdAount)

        // Then
        XCTAssertEqual(shareCurrency, Currency.cad.rawValue)
        XCTAssertNil(notShareCurrency)
    }

    /// When both objects has non-zero value, but one of them has nil as currency
    func testNilCurrencyNoneZero() {
        // Give
        let nilCurrencyNonZero = Amount(currency: nil, value: self.unimportantValue)
        let cadAmount = Amount(currency: Currency.cad.rawValue, value: self.unimportantValue)

        // When
        let notShareCurrency = Amount.shareSameCurrency(between: nilCurrencyNonZero, and: cadAmount)

        // Then
        XCTAssertNil(notShareCurrency)
    }


    // MARK: - Test cases for zero value

    /// When one of the Amount object has nil as currency,and zero as value
    func testNilCurrencyZero() {

        // Give
        let nilCurrencyZero = Amount.zero
        let cadAmount = Amount(currency: Currency.cad.rawValue, value: self.unimportantValue)

        // When
        let cadCurrency = Amount.shareSameCurrency(between: nilCurrencyZero, and: cadAmount)

        // Then
        XCTAssertEqual(cadCurrency, Currency.cad.rawValue)
    }

    // When both Amount objects have zero as value, but one has nil as currency.
    func testBothZeroOneNonNilCurrency() {

        // Give
        let nilCurrencyZero = Amount.zero
        let nonNilCurrencyZero = Amount(currency: Currency.cad.rawValue, value: 0)

        // When
        let cadCurrency = Amount.shareSameCurrency(between: nilCurrencyZero, and: nonNilCurrencyZero)

        // Then
        XCTAssertEqual(cadCurrency, Currency.cad.rawValue)
    }

    // When both Amount objects have zero as value, but different non-nil currencies.
    func testBothZeroDifferentCurrency() {

        // Give
        let cadZero = Amount(currency: Currency.cad.rawValue, value: 0)
        let usdZero = Amount(currency: Currency.usd.rawValue, value: 0)

        // When
        let notShareCurrency = Amount.shareSameCurrency(between: cadZero, and: usdZero)

        // Then
        XCTAssertNil(notShareCurrency)
    }

    /// When both of the Amount object has nil as currency,and zero as value
    func testBothNilCurrencyBothZero() {

        // Give
        let nilCurrencyZero0 = Amount.zero
        let nilCurrencyZero1 = Amount.zero

        // When
        let nilCurrency = Amount.shareSameCurrency(between: nilCurrencyZero0, and: nilCurrencyZero1)

        // Then
        XCTAssertNil(nilCurrency)
    }

    static var allTests = [
        ("testNonNilCurrenciesWithNonZeroValues", testNonNilCurrenciesWithNonZeroValues),
        ("testNilCurrencyNoneZero", testNilCurrencyNoneZero),
        ("testNilCurrencyZero", testNilCurrencyZero),
        ("testBothZeroOneNonNilCurrency", testBothZeroOneNonNilCurrency),
        ("testBothZeroDifferentCurrency", testBothZeroDifferentCurrency),
        ("testBothNilCurrencyBothZero", testBothNilCurrencyBothZero)
    ]
}
