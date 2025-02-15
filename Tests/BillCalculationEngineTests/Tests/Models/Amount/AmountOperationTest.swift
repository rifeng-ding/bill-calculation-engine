//
//  AmountOperationTest.swift
//
//
//  Created by Rifeng Ding on 2020-03-20.
//

import XCTest
@testable
import BillCalculationEngine

final class AmountOperationTest: XCTestCase {

    let intValueLarge: Decimal = 10
    let intValueSmall: Decimal = 5

    private var cadAmountLarge: Amount!
    private var cadAmountSmall: Amount!
    private var usdAmountLarge: Amount!

    override func setUp() {

        self.cadAmountLarge = Amount(currency: Currency.cad.rawValue, value: self.intValueLarge)
        self.cadAmountSmall = Amount(currency: Currency.cad.rawValue, value: self.intValueSmall)
        self.usdAmountLarge = Amount(currency: Currency.usd.rawValue, value: self.intValueLarge)
    }

    func testOperationsOnZero() {

        do {
            // Give
            var zeroForAdditon = Amount.zero
            var zeroForSubtaction = Amount.zero

            // When
            let additon = try Amount.zero + Amount.zero
            let subtraction = try Amount.zero - Amount.zero
            try zeroForAdditon += Amount.zero
            try zeroForSubtaction -= Amount.zero

            // Then
            XCTAssertEqual(additon, .zero)
            XCTAssertEqual(subtraction, .zero)
            XCTAssertEqual(zeroForAdditon, .zero)
            XCTAssertEqual(zeroForSubtaction, .zero)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }
    }

    func testValidAddition() {
        // Give: done in setUp

        // When
        var additionResult: Amount?
        do {
            additionResult = try self.cadAmountLarge + self.cadAmountSmall
            try self.cadAmountLarge += self.cadAmountSmall
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }

        // Then
        let decimalResult = self.intValueLarge + self.intValueSmall
        XCTAssertEqual(additionResult?.value, decimalResult)
        XCTAssertEqual(additionResult?.currency, Currency.cad.rawValue)
        XCTAssertEqual(self.cadAmountLarge.value, decimalResult)
        XCTAssertEqual(self.cadAmountLarge.currency, Currency.cad.rawValue)
    }

    func testIncompatibleCurrencyAddition() {
        // Give: done in setUp

        do {
            // When
            _ = try self.usdAmountLarge + self.cadAmountSmall
        } catch {
            // Then
            XCTAssertEqual(error as? AmountCalculationError, AmountCalculationError.incompatibleAmountCurrency)
        }

        // When
        XCTAssertThrowsError(try self.usdAmountLarge += self.cadAmountSmall) { error in
            // Then
            XCTAssertEqual(error as? AmountCalculationError, AmountCalculationError.incompatibleAmountCurrency)
        }
    }

    func testValidSubtraction() {
        // Give: done in setUp

        // When
        var additionResult: Amount?
        do {
            additionResult = try self.cadAmountLarge - self.cadAmountSmall
            try self.cadAmountLarge -= self.cadAmountSmall
        } catch {
            XCTFail()
        }

        // Then
        let decimalResult = self.intValueLarge - self.intValueSmall
        XCTAssertEqual(additionResult?.value, decimalResult)
        XCTAssertEqual(additionResult?.currency, Currency.cad.rawValue)
        XCTAssertEqual(self.cadAmountLarge.value, decimalResult)
        XCTAssertEqual(self.cadAmountLarge.currency, Currency.cad.rawValue)
    }

    func testIncompatibleCurrencySubtraction() {
        // Give: done in setUp

        do {
            // When
            _ = try self.usdAmountLarge - self.cadAmountSmall
        } catch {
            // Then
            XCTAssertEqual(error as? AmountCalculationError, AmountCalculationError.incompatibleAmountCurrency)
        }

        // When
        XCTAssertThrowsError(try self.usdAmountLarge -= self.cadAmountSmall) { error in
            // Then
            XCTAssertEqual(error as? AmountCalculationError, AmountCalculationError.incompatibleAmountCurrency)
        }
    }

    func testMultiplicationAndRounding() {
        // Give
        let amount = Amount(currency: Currency.cad.rawValue, value: 0.5)

        // When
        // 0.5 * 0.05 = 0.025 ≈ 0.03
        let result = amount * 0.05
        // Then
        XCTAssertEqual(result.value, Decimal(string: "0.03"))
        XCTAssertEqual(result.currency, Currency.cad.rawValue)
    }

    func testDivisionAndRounding() {
        // Give
        let amount = Amount(currency: Currency.cad.rawValue, value: 10)

        // When
        // 10 / 3 = 3.33333 ≈ 3.33
        let result = amount / 3

        // Then
        XCTAssertEqual(result.value, Decimal(string: "3.33"))
        XCTAssertEqual(result.currency, Currency.cad.rawValue)
    }

    static var allTests = [
        ("testOperationsOnZero", testOperationsOnZero),
        ("testValidAddition", testValidAddition),
        ("testIncompatibleCurrencyAddition", testIncompatibleCurrencyAddition),
        ("testValidSubtraction", testValidSubtraction),
        ("testIncompatibleCurrencySubtraction", testIncompatibleCurrencySubtraction),
        ("testMultiplicationAndRounding", testMultiplicationAndRounding),
        ("testDivisionAndRounding", testDivisionAndRounding)
    ]
}
