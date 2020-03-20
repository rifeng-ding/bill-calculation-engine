//
//  File.swift
//  
//
//  Created by Rifeng Ding on 2020-03-19.
//

import Foundation

extension Amount: Comparable {

    /// Returns a Boolean value indicating whether the value of the first
    /// Amount object is less than that of the second Amount object.
    ///
    /// This comparison doesn't consider the currency of the Amount object
    /// - Parameters:
    ///   - lhs: An Amount object to compare.
    ///   - rhs: Another Amount object to compare.
    public static func < (lhs: Amount, rhs: Amount) -> Bool {

        return lhs.value < rhs.value
    }


    /// Returns a Boolean value indicating whether two Amount objects are equal.
    ///
    /// If any one of the two Amount object has 0 as value, the currency of the two objects are ignored.
    /// If none of the two Amount objects has 0 as, and the currency for the 2 Amount object are different,
    /// false is always returned.
    /// - Parameters:
    ///   - lhs: An Amount object to compare.
    ///   - rhs: Another Amount object to compare.
    public static func == (lhs: Amount, rhs: Amount) -> Bool {

        guard lhs.currency == rhs.currency || lhs.value == 0 || rhs.value == 0 else {
            return false
        }
        return lhs.value == rhs.value
    }
}
