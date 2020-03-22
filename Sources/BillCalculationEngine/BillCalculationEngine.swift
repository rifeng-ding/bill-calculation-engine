//
//  BillCalculationEngine.swift
//
//
//  Created by Rifeng Ding on 2020-03-18.
//

public class BillCalculationEngine {

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

    public static func taxAmount(for products: [Product],
                                 taxes: [Tax]) throws -> Amount {

        var taxAmount = Amount.zero
        for product in products {
            // since taxAmount is accumulation of the calculations' results, the force try here is safe.
            try! taxAmount += product.taxAmount(for: taxes)
        }
        return taxAmount
    }

    // TODO: same discount can only be applied once
    public static func total(for products: [Product],
                             withTaxes taxes: [Tax],
                             discounts: [Discount]) throws -> BillTotal {

        let subtotal = try self.subtotal(for: products)
        let tax = try self.taxAmount(for: products, taxes: taxes)
        var total = try subtotal + tax

        var appliedDiscounts = [Discount]()
        var appliedDiscountIds = Set<String>()
        var totalDiscountedAmount = Amount.zero

        guard discounts.count > 0 && total > .zero else {
            return BillTotal(tax: tax,
                             total: total,
                             appliedDiscount: appliedDiscounts,
                             discountedAmount: totalDiscountedAmount)
        }

        for discount in discounts {
            if appliedDiscountIds.contains(discount.identifier) {
                continue
            }

            let result = try discount.apply(onSubtotal: total)
            guard result.discountedAmount > .zero else {
                break
            }
            appliedDiscountIds.insert(discount.identifier)
            appliedDiscounts.append(discount)
            // since the totalDiscountedAmount is an accumulaton of discountedAmount, the force try is safe
            try! totalDiscountedAmount += result.discountedAmount
            total = result.newSubtotal
        }

        return BillTotal(tax: tax,
                         total: total,
                         appliedDiscount: appliedDiscounts,
                         discountedAmount: totalDiscountedAmount)
    }
}
