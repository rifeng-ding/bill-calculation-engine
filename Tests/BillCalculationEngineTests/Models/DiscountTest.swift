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

    // MARK: - Fixed Amount Discount
    func testFixAmountLowerOrEqualThanSubtotal() {
        // Give
        let cadCurrency = Currency.cad.rawValue
        let discountCad50 = Discount(fixedAmount: Amount(currency: cadCurrency, value: 50))
        let discountCad100 = Discount(fixedAmount: Amount(currency: cadCurrency, value: 100))

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
        let discountCad200 = Discount(fixedAmount: amountCad200)

        // When
        var result: DiscountApplyingResult?
        do {
            result = try discountCad200.apply(onSubtotal: self.cadAmount100)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }
        // Then
        // 100 - 200 cannot be applied
        XCTAssertEqual(result?.discountedAmount, .zero)
        XCTAssertEqual(result?.newSubtotal, self.cadAmount100)
    }

    func testFixAmountWithInvalidCurrency() {
        // Give
        let discountUSD20 = Discount(fixedAmount: Amount(currency: Currency.usd.rawValue, value: 20))

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
        let discountCad0 = Discount(fixedAmount: .zero)

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
    func testPercentageWithNonZeroResult() {
        // Give
        let discount25Percent = Discount(percentage: 0.25)
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
        let discount25Percent = Discount(percentage: 0.25)
        // when
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

    static var allTests = [
        ("testFixAmountLowerOrEqualThanSubtotal", testFixAmountLowerOrEqualThanSubtotal),
        ("testFixAmountBiggerThanSubtotal", testFixAmountBiggerThanSubtotal),
        ("testFixAmountWithInvalidCurrency", testFixAmountWithInvalidCurrency),
        ("testFixedAmountZeroDiscount", testFixedAmountZeroDiscount),
        ("testPercentageWithNonZeroResult", testPercentageWithNonZeroResult),
        ("testPercentageWithRoundingToZeroResult", testPercentageWithRoundingToZeroResult)
    ]
}
