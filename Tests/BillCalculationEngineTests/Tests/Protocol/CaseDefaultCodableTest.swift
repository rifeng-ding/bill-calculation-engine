//
//  CaseDefaultTest.swift
//
//
//  Created by Rifeng Ding on 2020-03-21.
//

import XCTest
@testable
import BillCalculationEngine

private enum TestType: String, CaseDefaultCodable {

    static var defaultCase: TestType = unknown

    case unknown
    case known
}

private struct TestStruct: Codable {

    var type: TestType
}

final class CaseDefaultCodableTest: XCTestCase {

    func testRegularCase() {
        // Give
        let jsonInvalidRawValue = """
            {"type": "known"}
        """
        // When
        let jsonData = jsonInvalidRawValue.data(using: .utf8)!
        let testFallback = try! JSONDecoder().decode(TestStruct.self, from: jsonData)

        // Then
        XCTAssertEqual(testFallback.type, .known)
    }

    func testFallbackToDefault() {
        // Give
        let jsonInvalidRawValue = """
            {"type": "invalid raw type"}
        """
        // When
        let jsonData = jsonInvalidRawValue.data(using: .utf8)!
        let testFallback = try! JSONDecoder().decode(TestStruct.self, from: jsonData)

        // Then
        XCTAssertEqual(testFallback.type, .unknown)
    }

    static var allTests = [
        ("testFallbackToDefault", testFallbackToDefault),
    ]
}
