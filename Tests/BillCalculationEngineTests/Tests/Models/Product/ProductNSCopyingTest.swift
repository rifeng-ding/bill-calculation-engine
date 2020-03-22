//
//  File.swift
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

final class ProductNSCopyingTest: XCTestCase {

    func testCopy() {
        // Give:
        let orginalProduct = Product(identifier: "some id",
                                     name: "some name",
                                     category: .mains,
                                     price: Amount(currency: Currency.cad.rawValue, value: 10),
                                     isTaxExempt: false)

        // When
        let copy = orginalProduct.copy()

        // Then
        guard let copiedProduct = copy as? Product else {
            XCTFail("Copied object has wrong type")
            return
        }
        // This only means the identifiers are the same,
        // ebcuase Product conforms to Identifiable
        XCTAssertEqual(orginalProduct, copiedProduct)
        XCTAssertEqual(orginalProduct.name, copiedProduct.name)
        XCTAssertEqual(orginalProduct.category, copiedProduct.category)
        XCTAssertEqual(orginalProduct.price, copiedProduct.price)
        XCTAssertEqual(orginalProduct.isTaxExempt, copiedProduct.isTaxExempt)

        XCTAssertFalse(orginalProduct === copiedProduct)
    }

    static var allTests = [
        ("testCopy", testCopy)
    ]
}
