//
//  HostModel.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/20/25.
//

import Foundation

@Observable
final class HostModel: Equatable, Hashable, Identifiable, Codable {
    let address: String
    var label: String?
    var defaultHeaders: [HeaderModel]
    var endpoints = [EndpointModel]()
    
    var id: String {
        address
    }
    
    enum CodingKeys: String, CodingKey {
        case address
        case label
        case defaultHeaders
        case endpoints
    }
    
    init(address: String, label: String? = nil, defaultHeaders: [HeaderModel] = [], endpoints: [EndpointModel] = []) {
        self.address = address
        self.label = label
        self.endpoints = endpoints
        self.defaultHeaders = defaultHeaders
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(String.self, forKey: .address)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.defaultHeaders = try container.decode([HeaderModel].self, forKey: .defaultHeaders)
        self.endpoints = try container.decode([EndpointModel].self, forKey: .endpoints)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(label, forKey: .label)
        try container.encode(defaultHeaders, forKey: .defaultHeaders)
        try container.encode(endpoints, forKey: .endpoints)
    }
    
    static func == (lhs: HostModel, rhs: HostModel) -> Bool {
        lhs.address == rhs.address && lhs.defaultHeaders == rhs.defaultHeaders && lhs.endpoints == rhs.endpoints
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
        hasher.combine(defaultHeaders)
        hasher.combine(endpoints)
    }
}
