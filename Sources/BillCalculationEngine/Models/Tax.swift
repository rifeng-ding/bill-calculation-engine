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
        return _identifier ?? ""
    }
    internal let _identifier: String?

    public var percentage: Double {
        return _percentage ?? 0
    }
    internal let _percentage: Double?

    public var isEnabled: Bool {
        get {
            return _isEnabled ?? false
        }
        set {
            self._isEnabled = newValue
        }
    }
    internal var _isEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case name
        case applicableCategories
        case _identifier = "identifier"
        case _percentage = "percentage"
        case _isEnabled = "isEnabled"
    }

    init(identifier: String?,
         name: String?,
         percentage: Double?,
         isEnabled: Bool?,
         applicableCategories: [ProductCategory]?) {

        self.name = name
        self.applicableCategories = applicableCategories
        self._identifier = identifier
        self._percentage = percentage
        self._isEnabled = isEnabled
    }
}
