import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        // Amount
        testCase(AmountCurrencyTest.allTests),
        testCase(AmountOperationTest.allTests),
        testCase(AmountComparableTest.allTests),
        // Discount
        testCase(DiscountTest.allTests),
        testCase(BillCalculationEngineTests.allTests)
    ]
}
#endif
