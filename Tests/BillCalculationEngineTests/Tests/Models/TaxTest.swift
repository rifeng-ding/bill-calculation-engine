//
//  TaxTest.swift
//  
//
//  Created by Rifeng Ding on 2020-03-22.
//

import Foundation

//
//  AmountComparableTest.swift
//
//
//  Created by Rifeng Ding on 2020-03-20.
//

import XCTest
@testable
import BillCalculationEngine

final class TaxTest: XCTestCase {

    func testDefaultPropertyValues() {
        // Give
        let nilPropertiesTax = Tax(identifier: nil,
                                   name: nil,
                                   percentage: nil,
                                   isEnabled: nil,
                                   applicableCategories: nil)

        // When
        // Then
        XCTAssertEqual(nilPropertiesTax.identifier, "")
        XCTAssertEqual(nilPropertiesTax.percentage, 0)

        XCTAssertFalse(nilPropertiesTax.isEnabled)

        XCTAssertNil(nilPropertiesTax.name)
        XCTAssertNil(nilPropertiesTax.applicableCategories)
    }

    func testIsEnabledSetterAndGetter() {
        // Give
        let nilPropertiesTax = Tax(identifier: nil,
                                   name: nil,
                                   percentage: nil,
                                   isEnabled: nil,
                                   applicableCategories: nil)
        XCTAssertFalse(nilPropertiesTax.isEnabled)

        // When:
        nilPropertiesTax.isEnabled = true

        // Then
        XCTAssert(nilPropertiesTax.isEnabled)
    }

    static var allTests = [
        ("testDefaultPropertyValues", testDefaultPropertyValues),
        ("testIsEnabledSetterAndGetter", testIsEnabledSetterAndGetter)
    ]
}
