//
//  HeaderModel.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/20/25.
//

import Foundation

struct HeaderModel: Equatable, Hashable, Identifiable, Codable {
    let key: String
    let value: String
    var disabled: Bool
    
    init(key: String, value: String, disabled: Bool = false) {
        self.key = key
        self.value = value
        self.disabled = disabled
    }
    
    init(field: HTTPHeaderField, value: String) {
        self.key = field.rawValue
        self.value = value
        self.disabled = false
    }
    
    var id: String {
        "\(key):\(value)"
    }
}
