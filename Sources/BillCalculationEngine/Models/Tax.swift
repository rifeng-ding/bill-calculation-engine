//
//  File.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

public struct Tax: Codable, Identifiable {

    public let name: String?
    /// The category of the that the tax is applicable.
    ///
    /// When the value it's nil, means it can be applied to any of categorys
    public let applicableCategories: [ProductCategory]?

    public var identifier: String {
        return identifierOptional ?? ""
    }
    public let identifierOptional: String?

    public var percentage: Double {
        return percentageOptional ?? 0
    }
    public let percentageOptional: Double?

    public var isEnabled: Bool {
        get {
            return isEnabledOptional ?? false
        }
        set {
            self.isEnabledOptional = newValue
        }
    }
    public var isEnabledOptional: Bool?

    enum codingKeys: String, CodingKey {
        case name
        case applicableCategories
        case identifierOptional = "identifier"
        case percentageOptional = "percentage"
        case isEnabledOptional = "isEnabled"
    }

    init(identifier: String?,
         name: String?,
         percentage: Double?,
         isEnabled: Bool?,
         applicableCategories: [ProductCategory]?) {

        self.name = name
        self.applicableCategories = applicableCategories
        self.identifierOptional = identifier
        self.percentageOptional = percentage
        self.isEnabledOptional = isEnabled
    }
}
