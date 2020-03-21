//
//  ProductTest.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import XCTest
@testable
import BillCalculationEngine

final class ProductTest: XCTestCase {

    let wine = Product(name: "Wine",
                       category: .alcohol,
                       price: Amount(currency: Currency.cad.rawValue, value: 10))

    let wineTax = Tax(name: "Wine Tax",
                      percentage: 0.096,
                      isEabled: true,
                      applicableCategories: [.alcohol])

    let gst = Tax(name: "GST",
                  percentage: 0.05,
                  isEabled: true,
                  applicableCategories: nil)

    func testProductWithApplicableTaxes () {
        // Give: done with properties

        // When
        let taxAmount = wine.taxAmount(for: [wineTax, gst])

        // Then
        let wineTaxAmount = wine.price.multiply(by: wineTax.percentage)
        let gstAmount = wine.price.multiply(by: gst.percentage)
        XCTAssertEqual(taxAmount, try! wineTaxAmount + gstAmount)
    }

    func testProductWithDisabledTax() {
        // Give
        let disabledTax = Tax(name: "some tax",
                              percentage: 0.5,
                              isEabled: false,
                              applicableCategories: nil)
        // When
        let taxAmount = wine.taxAmount(for: [wineTax, gst, disabledTax])

        // Then
        let wineTaxAmount = wine.price.multiply(by: wineTax.percentage)
        let gstAmount = wine.price.multiply(by: gst.percentage)
        XCTAssertEqual(taxAmount, try! wineTaxAmount + gstAmount)
    }

    func testProductWithInapplicableTax() {
       // Give
        let inapplicableTax = Tax(name: "imaginary appetizer & main tax",
                              percentage: 0.15,
                              isEabled: true,
                              applicableCategories: [.appetizers, .mains])
        // When
        let taxAmount = wine.taxAmount(for: [wineTax, gst, inapplicableTax])

        // Then
        let wineTaxAmount = wine.price.multiply(by: wineTax.percentage)
        let gstAmount = wine.price.multiply(by: gst.percentage)
        XCTAssertEqual(taxAmount, try! wineTaxAmount + gstAmount)
    }

    static var allTests = [
        ("testProductWithApplicableTaxes", testProductWithApplicableTaxes),
        ("testProductWithDisabledTax", testProductWithDisabledTax),
        ("testProductWithInapplicableTax", testProductWithInapplicableTax)
    ]
}
