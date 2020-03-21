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

    // TODO: minimum purchase for the discount?
    public static func applyDiscounts(_ discounts: [Discount], for products: [Product]) throws -> (appliedDiscounts: [Discount] , discountedAmount: Amount, newSubtotal: Amount) {

        var appliedDiscounts = [Discount]()
        var totalDiscountedAmount = Amount.zero
        var subtotal = try self.subtotal(for: products)

        guard discounts.count > 0, subtotal > .zero else {
            return (appliedDiscounts, totalDiscountedAmount, subtotal)
        }

        for discount in discounts {
            let result = try discount.apply(onSubtotal: subtotal)
            guard result.discountedAmount > .zero else {
                break
            }
            appliedDiscounts.append(discount)
            // since the totalDiscountedAmount is an accumulaton of discountedAmount, the force try is safe
            try! totalDiscountedAmount += result.discountedAmount
            subtotal = result.newSubtotal
        }

        return (appliedDiscounts, totalDiscountedAmount, subtotal)
    }

    public static func taxAmount(for products: [Product], taxes: [Tax]) throws -> Amount {

        var taxAmount = Amount.zero
        for product in products {
            // since taxAmount is accumulation of the calculations' results, the force try here is safe.
            try! taxAmount += product.taxAmount(for: taxes)
        }
        return taxAmount
    }
}
