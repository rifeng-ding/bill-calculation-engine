//
//  IdentifiableTest.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import XCTest
@testable
import BillCalculationEngine

private struct IdentifiableModel: Identifiable {

    let identifier: String
    let someOtherProperty: String
}

final class IdentifiableTest: XCTestCase {

    func testIdentifiability() {
        // Give
        let sharedId = "sharedId"
        let sharedPropertyValue = "Does property matter?"
        let objectSharedId0 = IdentifiableModel(identifier: sharedId, someOtherProperty: sharedPropertyValue)
        let objectSharedId1 = IdentifiableModel(identifier: sharedId, someOtherProperty: "It doesn't matter.")
        let objectOtherId = IdentifiableModel(identifier: "someOtherId", someOtherProperty: sharedPropertyValue)

        // When
        // Then
        XCTAssertEqual(objectSharedId0, objectSharedId1)
        XCTAssertNotEqual(objectSharedId0, objectOtherId)
    }

    static var allTests = [
        ("testIdentifiability", testIdentifiability),
    ]
}
