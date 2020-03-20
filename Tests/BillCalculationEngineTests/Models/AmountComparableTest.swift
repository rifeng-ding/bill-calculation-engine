//
//  AmountComparableTest.swift
//
//
//  Created by Rifeng Ding on 2020-03-20.
//

import XCTest
@testable
import BillCalculationEngine

final class AmountComparableTest: XCTestCase {

    private enum Currency: String {
        case cad = "CAD"
        case usd = "USD"
    }

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

    func testComparable() {
        // Give: done in setUp

        // When
        // Then
        XCTAssertTrue(self.cadAmountSmall < self.cadAmountLarge)
        XCTAssertTrue(self.cadAmountSmall < self.usdAmountLarge)
        XCTAssertTrue(self.cadAmountSmall == self.cadAmountSmall)
        XCTAssertTrue(self.cadAmountSmall != self.cadAmountLarge)
        XCTAssertTrue(self.usdAmountLarge != self.cadAmountLarge)
    }

    static var allTests = [
        ("testComparable", testComparable)
    ]
}
