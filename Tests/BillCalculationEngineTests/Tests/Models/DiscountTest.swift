//
//  DiscountTest.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import XCTest
@testable
import BillCalculationEngine

final class DiscountTest: XCTestCase {

    let cadAmount100 = Amount(currency: Currency.cad.rawValue, value: 100)

    // MARK: Unknow Type Discount
    func testUnknownTypeDiscount() {
        // Give
        let unknownTypeDiscount = Discount.unknown

        // when
        var result: DiscountApplyingResult?
        do {
           result = try unknownTypeDiscount.apply(onSubtotal: self.cadAmount100)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }

        // Then
        XCTAssertEqual(result?.discountedAmount, .zero)
        XCTAssertEqual(result?.newSubtotal, self.cadAmount100)
    }

    // MARK: - Fixed Amount Discount
    func testInitWithInvalidFixedAmount() {
        // Give
        let discount = Discount(identifier:"11111",
                                fixedAmount: Amount(currency: Currency.cad.rawValue, value: -10))
        // When
        // Then
        XCTAssertEqual(discount.type, .fixedAmount)
        XCTAssertEqual(discount.amount, .zero)
    }

    func testFixAmountLowerOrEqualThanSubtotal() {
        // Give
        let cadCurrency = Currency.cad.rawValue
        let discountCad50 = Discount(identifier:"11111",
                                     fixedAmount: Amount(currency: cadCurrency, value: 50))
        let discountCad100 = Discount(identifier:"22222",
                                      fixedAmount: Amount(currency: cadCurrency, value: 100))

        // When
        var resultDiscount50: DiscountApplyingResult?
        var resultDiscount100: DiscountApplyingResult?

        do {
            resultDiscount50 = try discountCad50.apply(onSubtotal: self.cadAmount100)
            resultDiscount100 = try discountCad100.apply(onSubtotal: self.cadAmount100)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }

        // Then
        // 100 - 50 = 50
        XCTAssertEqual(resultDiscount50?.discountedAmount, discountCad50.amount!)
        XCTAssertEqual(resultDiscount50?.newSubtotal, Amount(currency: cadCurrency, value: 50))
        // 100 - 100 = 0
        XCTAssertEqual(resultDiscount100?.discountedAmount, discountCad100.amount!)
        XCTAssertEqual(resultDiscount100?.newSubtotal, .zero)
    }

    func testFixAmountBiggerThanSubtotal() {
        // Give
        let cadCurrency = Currency.cad.rawValue
        let amountCad200 = Amount(currency: cadCurrency, value: 200)
        let discountCad200 = Discount(identifier:"11111",
                                      fixedAmount: amountCad200)

        // When
        var result: DiscountApplyingResult?
        do {
            result = try discountCad200.apply(onSubtotal: self.cadAmount100)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }
        // Then
        // 100 - 200 = 0 as new subtotal cannot become negative
        XCTAssertEqual(result?.discountedAmount, self.cadAmount100)
        XCTAssertEqual(result?.newSubtotal, .zero)
    }

    func testFixAmountWithInvalidCurrency() {
        // Give
        let discountUSD20 = Discount(identifier:"11111",
                                     fixedAmount: Amount(currency: Currency.usd.rawValue, value: 20))

        do {
            // When
            _ = try discountUSD20.apply(onSubtotal: self.cadAmount100)
        } catch {
            // Then
            XCTAssertEqual(error as? BillCalculationEngineErrror, BillCalculationEngineErrror.invalidDiscountCurrency)
        }
    }

    func testFixedAmountZeroDiscount() {
        // Give
        let discountCad0 = Discount(identifier:"11111",
                                    fixedAmount: Amount(currency: Currency.cad.rawValue, value: 0))

        // When
        var result: DiscountApplyingResult?
        do {
            result = try discountCad0.apply(onSubtotal: self.cadAmount100)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }
        // Then
        // 100 - 0  = 100
        XCTAssertEqual(result?.discountedAmount, .zero)
        XCTAssertEqual(result?.newSubtotal, self.cadAmount100)
    }

    // MARK: - Percentage Discount

    func testInitWithInvalidPercentage() {
        // Give
        let discount = Discount(identifier:"11111",
                                percentage: 1.2)
        // When
        // Then
        XCTAssertEqual(discount.type, .percentage)
        XCTAssertEqual(discount.percentage, 1)
    }

    func testPercentageWithNonZeroResult() {
        // Give
        let discount25Percent = Discount(identifier:"11111",
                                         percentage: 0.25)
        // when
        // When
        var result: DiscountApplyingResult?
        do {
            result = try discount25Percent.apply(onSubtotal: self.cadAmount100)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }
        // Then
        // 100 * 0.25 = 25
        let amountCAD25 = Amount(currency: Currency.cad.rawValue, value: 25)
        XCTAssertEqual(result?.discountedAmount, amountCAD25)
        XCTAssertEqual(result?.newSubtotal, (try! self.cadAmount100 - amountCAD25))
    }

    func testPercentageWithRoundingToZeroResult() {
        // Give
        let oneCent = Amount(currency: Currency.cad.rawValue, value: 0.01)
        let discount25Percent = Discount(identifier:"11111",
                                         percentage: 0.25)
        // When
        var result: DiscountApplyingResult?
        do {
            result = try discount25Percent.apply(onSubtotal: oneCent)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }
        // Then
        // 0.01 * 0.25 = 0.0025 ≈ 0
        XCTAssertEqual(result?.discountedAmount, oneCent)
        XCTAssertEqual(result?.newSubtotal, .zero)
    }

    // This test case may happen if the Discount is decoded from JSON
    func testPercentageWithInvalidPercentage() {
        // Give
        let discount120Percentage = Discount(identifier:"11111",
                                             withAnyPercentage: 1.20)
        // When
        var result: DiscountApplyingResult?
        do {
            result = try discount120Percentage.apply(onSubtotal: self.cadAmount100)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }
        // Then
        XCTAssertEqual(result?.discountedAmount, .zero)
        XCTAssertEqual(result?.newSubtotal, self.cadAmount100)
    }

    static var allTests = [
        ("testUnknownTypeDiscount", testUnknownTypeDiscount),

        ("testInitWithInvalidFixedAmount", testInitWithInvalidFixedAmount),
        ("testFixAmountLowerOrEqualThanSubtotal", testFixAmountLowerOrEqualThanSubtotal),
        ("testFixAmountBiggerThanSubtotal", testFixAmountBiggerThanSubtotal),
        ("testFixAmountWithInvalidCurrency", testFixAmountWithInvalidCurrency),
        ("testFixedAmountZeroDiscount", testFixedAmountZeroDiscount),

        ("testInitWithInvalidPercentage", testInitWithInvalidPercentage),
        ("testPercentageWithNonZeroResult", testPercentageWithNonZeroResult),
        ("testPercentageWithRoundingToZeroResult", testPercentageWithRoundingToZeroResult),
        ("testPercentageWithInvalidPercentage", testPercentageWithInvalidPercentage)
    ]
}
