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
            let (discountedAmount, newSubtotal) = try self.apply(discount: discount, on: subtotal)
            guard discountedAmount > .zero else {
                break
            }
            appliedDiscounts.append(discount)
            // since the totalDiscountedAmount is an accumulaton of discountedAmount, the force try is safe
            try! totalDiscountedAmount += discountedAmount
            subtotal = newSubtotal
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

    // MARK: - Interanl Methods
    // TODO: move to Discount?
    // TODO: internal method throw public error seems a bit odd
    internal static func apply(discount: Discount, on subtotal: Amount) throws -> (discountedAmount: Amount, newSubtotal: Amount) {

        switch discount.type {
        case .fixedAmount:
            guard let discountAmount = discount.amount else {
                return (.zero, subtotal)
            }
            guard let currency = Amount.shareSameCurrency(between: subtotal, and: discountAmount) else {
                throw BillCalculationEngineErrror.invalidDiscountCurrency
            }
            // Since the above guard already checked the currency, here the force try is safe
            let newSubtotal = subtotal > discountAmount ? (try! subtotal - discountAmount) : Amount(currency: currency, value: 0)
            let discountedAmount = subtotal > discountAmount ? discountAmount : subtotal
            return (discountedAmount, newSubtotal)

        case .percentage:
            guard let percentage = discount.percentage else {
                return (.zero, subtotal)
            }
            let discountedAmount = subtotal.multiply(by: percentage)
            // since the discountedAmount is derived from the subtotal, the force try is safe
            let newSubtotal = try! subtotal - discountedAmount
            return (discountedAmount, newSubtotal)
        }
    }
}
