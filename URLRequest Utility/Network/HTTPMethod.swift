//
//  HTTPMethod.swift
//  Space Traders iOS
//
//  Created by David Brown on 4/5/24.
//

import Foundation

enum HTTPMethod: String, CaseIterable, Codable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
