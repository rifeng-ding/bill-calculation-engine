//
//  AmountTest.swift
//
//
//  Created by Rifeng Ding on 2020-03-20.
//

import XCTest
@testable
import BillCalculationEngine

final class AmountTest: XCTestCase {

    func testDefaultPropertyValues() {
        // Give
        let nilPropertiesAmount = Amount(currency: nil, value: nil)

        // When
        // Then
        XCTAssertEqual(nilPropertiesAmount.value, 0)
        XCTAssertNil(nilPropertiesAmount.currency)
    }

    func testSetValueInString() {
        // Give
        var nilPropertiesAmount = Amount(currency: nil, value: nil)

        // When
        nilPropertiesAmount.valueInString = "19.89"
        // Then
        XCTAssertEqual(nilPropertiesAmount.value, 19.89)
    }

    func testSetInvalidValueInString() {
        // Give
        var nilPropertiesAmount = Amount(currency: nil, value: nil)

        // When
        nilPropertiesAmount.valueInString = "non number string"
        // Then
        XCTAssertEqual(nilPropertiesAmount.value, 0)
    }

    static var allTests = [
        ("testDefaultPropertyValues", testDefaultPropertyValues),
        ("testSetValueInString", testSetValueInString),
        ("testSetInvalidValueInString", testSetInvalidValueInString)
    ]
}
