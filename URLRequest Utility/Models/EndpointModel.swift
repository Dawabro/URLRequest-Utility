//
//  EndpointModel.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/20/25.
//

import Foundation

@Observable
final class EndpointModel: Equatable, Hashable, Identifiable, Codable {
    let path: String
    let httpMethod: HTTPMethod
    var queryItems: [QueryItemModel]
    var responses: [RequestResponse]
    
    var id: String {
        path
    }
    
    enum CodingKeys: String, CodingKey {
        case path
        case httpMethod
        case queryItems
        case responses
    }
    
    init(path: String, httpMethod: HTTPMethod = .get, queryItems: [QueryItemModel] = []) {
        self.path = path
        self.httpMethod = httpMethod
        self.queryItems = queryItems
        self.responses = []
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.path = try container.decode(String.self, forKey: .path)
        self.httpMethod = try container.decode(HTTPMethod.self, forKey: .httpMethod)
        self.queryItems = try container.decodeIfPresent([QueryItemModel].self, forKey: .queryItems) ?? []
        self.responses = try container.decodeIfPresent([RequestResponse].self, forKey: .responses) ?? []
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(httpMethod, forKey: .httpMethod)
        try container.encode(queryItems, forKey: .queryItems)
        try container.encode(responses, forKey: .responses)
    }
    
    static func == (lhs: EndpointModel, rhs: EndpointModel) -> Bool {
        lhs.path == rhs.path && lhs.httpMethod == rhs.httpMethod
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(httpMethod)
    }
}
