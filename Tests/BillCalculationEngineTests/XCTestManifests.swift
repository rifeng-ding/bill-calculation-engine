import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AmountCurrencyTest.allTests),
        testCase(AmountOperationTest.allTests),
        testCase(AmountComparableTest.allTests),
        testCase(BillCalculationEngineTests.allTests)
    ]
}
#endif
