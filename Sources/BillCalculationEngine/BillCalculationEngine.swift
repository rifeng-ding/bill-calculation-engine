//
//  BillCalculationEngine.swift
//
//
//  Created by Rifeng Ding on 2020-03-18.
//

public class BillCalculationEngine {

    /// Calculate the subtotal of given products.
    /// - Parameter products: Products to calcuate the subtotal.
    public static func subtotal(for products: [Product]) throws -> Amount {
        
        guard products.count > 0 else {
            return Amount.zero
        }
        var subtotal = Amount.zero
        for product in products {
            do {
                try subtotal += product.price
            } catch _ as AmountCalculationError {
                throw BillCalculationEngineErrror.inconsisentCurrencyAmongProducts
            }
        }
        return subtotal
    }


    /// Calcuate the total amount of tax for give products and taxes.
    /// - Parameters:
    ///   - products: Products to calcuate the tax.
    ///   - taxes: Taxes for calcuate the tax.
    ///
    /// 1. If any tax is has `isEnabled == false`,
    /// then it won't be applied to any product.
    ///
    /// 2. For tax that has `applicableCategories == nil`,
    /// then it will be applied to products of any categories.
    ///
    /// 3. For tax that has `applicableCategories` specified,
    /// then it will only be applied to products of those specified categories.
    public static func taxAmount(for products: [Product],
                                 taxes: [Tax]) throws -> Amount {

        var taxAmount = Amount.zero
        for product in products {
            // since taxAmount is accumulation of the calculations' results, the force try here is safe.
            try! taxAmount += product.taxAmount(for: taxes)
        }
        return taxAmount
    }

    /// Calcuate the bill for given products, taxes and discounts.
    /// - Parameters:
    ///   - products: Products to calculate the bill.
    ///   - taxes: Taxes for calculate the bill.
    ///   - discounts: Discount for calculate the bill.
    ///
    /// 1. Tax is calculated based on the subtotal, before any discounts.
    ///
    /// 2. Discounted amount are calculated after taxes, i.e. discounts are applied to subtotal + tax.
    ///
    /// 3. Discounts will be applied in the same order of how they are passed in through `discounts`.
    /// If any number of discounts at the top of the array, have already brought the total of the bill to 0,
    /// then the remaining discount(s) won't be applied, and won't be included in `appliedDiscounts` of the returned `Bill` object.
    ///
    /// 4. Please note that no stand-alone method is provided for applying discount(s) on a given amount.
    /// This is on prupose for avoiding violation of business logic,
    /// i.e. discounts should be applied in the same order of how they are passed into the bill calculation method.
    /// If any number of discounts at the top of the array, have already brought the total of the bill to 0,
    /// then the remaining discount(s) won't be applied, and won't be included in appliedDiscounts of the returned Bill object.
    public static func bill(for products: [Product],
                             withTaxes taxes: [Tax],
                             discounts: [Discount]) throws -> Bill {

        let subtotal = try self.subtotal(for: products)
        let tax = try self.taxAmount(for: products, taxes: taxes)
        var total = try subtotal + tax

        var appliedDiscounts = [Discount]()
        var appliedDiscountIds = Set<String>()
        var totalDiscountedAmount = Amount.zero

        guard discounts.count > 0 && total > .zero else {
            return Bill(subtotal: subtotal,
                        tax: tax,
                        appliedDiscounts: appliedDiscounts,
                        discountedAmount: totalDiscountedAmount,
                        total: total)
        }

        for discount in discounts {
            if appliedDiscountIds.contains(discount.identifier) {
                continue
            }

            let result = try discount.apply(onAmount: total)
            guard result.discountedAmount > .zero else {
                break
            }
            appliedDiscountIds.insert(discount.identifier)
            appliedDiscounts.append(discount)
            // since the totalDiscountedAmount is an accumulaton of discountedAmount, the force try is safe
            try! totalDiscountedAmount += result.discountedAmount
            total = result.newSubtotal
        }

        return Bill(subtotal: subtotal,
                    tax: tax,
                    appliedDiscounts: appliedDiscounts,
                    discountedAmount: totalDiscountedAmount,
                    total: total)
    }
}
