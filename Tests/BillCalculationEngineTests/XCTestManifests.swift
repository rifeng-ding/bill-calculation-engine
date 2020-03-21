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
        // Product
        testCase(ProductTest.allTests),
        // Identifiable
        testCase(IdentifiableTest.allTests),
        // CaseDefaultCodableTest
        testCase(CaseDefaultCodableTest.allTests),
        // BillCalculationEngine
        testCase(BillCalculationEngineTests.allTests)
    ]
}
#endif
