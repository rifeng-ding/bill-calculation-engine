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

    let wine = Product(identifier: "12345",
                       name: "Wine",
                       category: .alcohol,
                       price: Amount(currency: Currency.cad.rawValue, value: 10),
                       isTaxExempt: false)

    let wineTax = Tax(identifier: "11111",
                      name: "Wine Tax",
                      percentage: 0.096,
                      isEnabled: true,
                      applicableCategories: [.alcohol])

    let gst = Tax(identifier: "22222",
                  name: "GST",
                  percentage: 0.05,
                  isEnabled: true,
                  applicableCategories: nil)

    func testProductWithApplicableTaxes () {
        // Give: done with properties

        // When
        let taxAmount = self.wine.taxAmount(for: [wineTax, gst])

        // Then
        let wineTaxAmount = self.wine.price.multiply(by: wineTax.percentageDouble)
        let gstAmount = self.wine.price.multiply(by: gst.percentageDouble)
        XCTAssertEqual(taxAmount, try! wineTaxAmount + gstAmount)
    }

    func testProductWithDisabledTax() {
        // Give
        let disabledTax = Tax(identifier: "33333",
                              name: "some tax",
                              percentage: 0.5,
                              isEnabled: false,
                              applicableCategories: nil)
        // When
        let taxAmount = self.wine.taxAmount(for: [wineTax, gst, disabledTax])

        // Then
        let wineTaxAmount = self.wine.price.multiply(by: wineTax.percentageDouble)
        let gstAmount = self.wine.price.multiply(by: gst.percentageDouble)
        XCTAssertEqual(taxAmount, try! wineTaxAmount + gstAmount)
    }

    func testProductWithInapplicableTax() {
        // Give
        let inapplicableTax = Tax(identifier: "33333",
                                  name: "imaginary appetizer & main tax",
                                  percentage: 0.15,
                                  isEnabled: true,
                                  applicableCategories: [.appetizers, .mains])
        // When
        let taxAmount = self.wine.taxAmount(for: [wineTax, gst, inapplicableTax])

        // Then
        let wineTaxAmount = self.wine.price.multiply(by: wineTax.percentageDouble)
        let gstAmount = self.wine.price.multiply(by: gst.percentageDouble)
        XCTAssertEqual(taxAmount, try! wineTaxAmount + gstAmount)
    }

    func testTaxExemptProduct() {
        // Give
        let taxExemptWine = Product(identifier: "12345",
                                    name: "Wine",
                                    category: .alcohol,
                                    price: Amount(currency: Currency.cad.rawValue, value: 10),
                                    isTaxExempt: true)
        // When
        let taxAmount = taxExemptWine.taxAmount(for: [wineTax, gst])

        // Then
        XCTAssertEqual(taxAmount, .zero)
    }

    static var allTests = [
        ("testProductWithApplicableTaxes", testProductWithApplicableTaxes),
        ("testProductWithDisabledTax", testProductWithDisabledTax),
        ("testProductWithInapplicableTax", testProductWithInapplicableTax),
        ("testTaxExemptProduct", testTaxExemptProduct)
    ]
}
