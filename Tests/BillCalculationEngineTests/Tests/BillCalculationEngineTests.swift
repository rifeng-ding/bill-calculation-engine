import XCTest
@testable
import BillCalculationEngine

final class BillCalculationEngineTests: XCTestCase {

    private let priceValues: [Decimal] = [2.99, 3.5, 4.1, 15.99, 4.49]
    private static let testingCategory = ProductCategory.alcohol

    private let tax = Tax(identifier: "tax id",
                          name: "test total tax",
                          percentage: 0.05,
                          isEnabled: true,
                          applicableCategories: [testingCategory])

    private lazy var cadProducts: [Product] = {

        var products = [Product]()
        for priceValue in self.priceValues {
            let product = self.mockProduct(withPrice: Amount(currency: Currency.cad.rawValue, value: priceValue))
            products.append(product)
        }
        return products
    }()

    private func mockProduct(withPrice price: Amount) -> Product {

        return Product(identifier: "not important",
                       name: "not important",
                       category: Self.testingCategory,
                       price: price,
                       isTaxExempt: false)
    }

    // MARK: - Tests
    func testSubtotal() {
        // Give: done by properties

        // When
        var subtotal: Amount?
        do {
            subtotal = try BillCalculationEngine.subtotal(for: self.cadProducts)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }

        // Then
        let actualSubtotalValue = self.priceValues.reduce(0, +)
        let actualSubtotal = Amount(currency: Currency.cad.rawValue, value: actualSubtotalValue)
        XCTAssertEqual(subtotal, actualSubtotal)
    }

    func testSubtotalWithEmptyProducts() {

        // When
        var subtotal: Amount?
        do {
            subtotal = try BillCalculationEngine.subtotal(for: [])
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }

        // Then
        XCTAssertEqual(subtotal, .zero)
    }

    func testSubtotalWithInconsisentCurrency() {
        // Give
        let usdProduct = self.mockProduct(withPrice: Amount(currency: Currency.usd.rawValue, value: 10))
        let mixProducts = self.cadProducts + [usdProduct]

        // When
        // Then
        do {
            _ = try BillCalculationEngine.subtotal(for: mixProducts)
        } catch {
            XCTAssertEqual(error as? BillCalculationEngineErrror, BillCalculationEngineErrror.inconsisentCurrencyAmongProducts)
        }
    }

    func testTotalWithNoDiscuout() {
        // Give: done by properties

        // When
        var billTotal: BillTotal?
        do {
            billTotal = try BillCalculationEngine.total(for: self.cadProducts,
                                                        withTaxes: [self.tax],
                                                        discounts: [])
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }

        // Then
        let actualTotal = try! BillCalculationEngine.subtotal(for: self.cadProducts)
        let actualTax = try! BillCalculationEngine.taxAmount(for: self.cadProducts, taxes: [self.tax])
        XCTAssertEqual(billTotal!.total, try! actualTotal + actualTax)
        XCTAssertEqual(billTotal!.tax, actualTax)
        XCTAssertEqual(billTotal!.appliedDiscount, [])
        XCTAssertEqual(billTotal!.discountedAmount, .zero)
    }

    /// When applying two discounts, if the first discout already reduce the total to zero,
    /// then only the first discount is applied, and the new total would be 0.
    ///
    /// This test case also covers:
    /// 1. Apply only one discount.
    ///
    /// 2. It indirectly proves that "the order of applied discount matter", as otherwise, both discount will be applied.
    ///
    /// NOTE:
    /// 1. Type of the discount doesn't matter, as it has been tested by apply(onSubtotal:) on Discount.
    ///
    /// 2. BillCalculationEngine.taxAmount(for:taxes:) is used but not explicitly tested here,
    /// becuase based on its implementation, it's already been tested by taxAmount(for:) on product.
    func testTotalWithFirstAmountDicountBiggerThanOriginalTotal() {
        // Give:
        let fixedAmountDiscountValues: [Decimal] = [100, 10]
        let discountIds = ["1", "2"]
        XCTAssertEqual(fixedAmountDiscountValues.count, discountIds.count)

        let subtotal = try! BillCalculationEngine.subtotal(for: self.cadProducts)
        XCTAssert(subtotal.value < fixedAmountDiscountValues[0],
                  "Prepared fixed amount discount value is smaller than the mock subtotal")

        var discounts = [Discount]()
        for (index, value) in fixedAmountDiscountValues.enumerated() {
            let amount = Amount(currency: Currency.cad.rawValue, value: value)
            let discount = Discount(identifier: discountIds[index], fixedAmount: amount)
            discounts.append(discount)
        }

        // When
        var billTotal: BillTotal?
        do {
            billTotal = try BillCalculationEngine.total(for: self.cadProducts,
                                                        withTaxes: [self.tax],
                                                        discounts: discounts)
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }

        // Then
        let actualTotal = try! BillCalculationEngine.subtotal(for: self.cadProducts)
        let actualTax = try! BillCalculationEngine.taxAmount(for: self.cadProducts, taxes: [self.tax])
        let originalTotal = try! actualTotal + actualTax
        XCTAssertEqual(billTotal!.total, .zero)
        XCTAssertEqual(billTotal!.tax, actualTax)
        XCTAssertEqual(billTotal!.appliedDiscount, [discounts[0]])
        XCTAssertEqual(billTotal!.discountedAmount, originalTotal)
    }

    /// One disocunt can only be applied once
    func testTotalDuplicateDiscounts() {

        // Give:
        let amount = Amount(currency: Currency.cad.rawValue, value: 10)
        let discount = Discount(identifier: "123", fixedAmount: amount)

        // When
        var billTotal: BillTotal?
        do {
            billTotal = try BillCalculationEngine.total(for: self.cadProducts,
                                                        withTaxes: [self.tax],
                                                        discounts: [discount, discount])
        } catch {
            XCTFail("Unexcepted error: \(error)")
        }

        // Then
        let actualTotal = try! BillCalculationEngine.subtotal(for: self.cadProducts)
        let actualTax = try! BillCalculationEngine.taxAmount(for: self.cadProducts, taxes: [self.tax])
        let originalTotal = try! actualTotal + actualTax
        let discountResult = try! discount.apply(onAmount: originalTotal)
        XCTAssertEqual(billTotal!.total, discountResult.newSubtotal)
        XCTAssertEqual(billTotal!.tax, actualTax)
        XCTAssertEqual(billTotal!.appliedDiscount, [discount])
        XCTAssertEqual(billTotal!.discountedAmount, discountResult.discountedAmount)
    }

    static var allTests = [
        ("testSubtotal", testSubtotal),
        ("testSubtotalWithEmptyProducts", testSubtotalWithEmptyProducts),
        ("testSubtotalWithInconsisentCurrency", testSubtotalWithInconsisentCurrency),
        ("testTotalWithNoDiscuout", testTotalWithNoDiscuout),
        ("testTotalWithFirstAmountDicountBiggerThanOriginalTotal", testTotalWithFirstAmountDicountBiggerThanOriginalTotal),
        ("testTotalDuplicateDiscounts", testTotalDuplicateDiscounts)
    ]
}
