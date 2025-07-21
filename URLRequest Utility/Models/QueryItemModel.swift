//
//  QueryItemModel.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/20/25.
//

import Foundation

struct QueryItemModel: Identifiable, Equatable, Hashable, Codable {
    let name: String
    let value: String
    var disabled: Bool
    
    var id: String {
        "\(name)=\(value)"
    }
    
    init(name: String, value: String, disabled: Bool = false) {
        self.name = name
        self.value = value
        self.disabled = disabled
    }
}
