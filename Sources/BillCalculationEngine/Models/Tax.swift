//
//  File.swift
//  
//
//  Created by Rifeng Ding on 2020-03-18.
//

import Foundation

/// The tax object for the BillCalculationEngine.
public class Tax: Codable, Identifiable {

    /// The name of the tax.
    public let name: String?
    
    /// The category of the that the tax is applicable.
    ///
    /// When the value is nil, it means the tax can be applied to any of categories.
    public let applicableCategories: [ProductCategory]?

    /// The identifer of the tax.
    ///
    /// The default value is an empty string.
    public var identifier: String {
        return _identifier ?? ""
    }
    internal let _identifier: String?

    /// The percentage of the tax.
    ///
    /// The default value is 0.
    public var percentage: Double {
        return _percentage ?? 0
    }
    internal let _percentage: Double?

    /// A boolean value indicating if the tax is enabled.
    ///
    /// The default value is `false`.
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

    public init(identifier: String?,
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
