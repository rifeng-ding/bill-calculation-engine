//
//  Product+NSCopying.swift
//  
//
//  Created by Rifeng Ding on 2020-03-22.
//

import Foundation

extension Product: NSCopying {

    public func copy(with zone: NSZone? = nil) -> Any {

        let copy = Product(identifier: self.identifier,
                           name: self.name,
                           category: self.category,
                           price: self.price,
                           isTaxExempt: self.isTaxExempt)
        return copy
    }
}
