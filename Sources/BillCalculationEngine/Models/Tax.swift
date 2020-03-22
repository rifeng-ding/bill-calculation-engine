//
//  File.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

public struct Tax: Codable, Identifiable {

    public let identifier: String
    public let name: String
    public let percentage: Double
    public var isEnabled: Bool
    /// The category of the that the tax is applicable.
    ///
    /// When the value it's nil, means it can be applied to any of categorys
    public let applicableCategories: [ProductCategory]?
}
