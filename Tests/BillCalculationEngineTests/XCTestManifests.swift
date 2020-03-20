import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AmountCurrencyTest.allTests),
        testCase(BillCalculationEngineTests.allTests)
    ]
}
#endif
