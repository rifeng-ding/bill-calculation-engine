//
//  File.swift
//  
//
//  Created by Rifeng Ding on 2020-03-21.
//

import Foundation

extension Amount: CustomStringConvertible {

    public var description: String {
        
        return "Amount: \(self.currency ?? "nil") \(self.value)"
    }
}
