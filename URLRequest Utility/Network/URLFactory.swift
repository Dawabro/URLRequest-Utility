//
//  URLFactory.swift
//  SpaceTraderiOS-SwifUI2
//
//  Created by David W. Brown on 1/1/22.
//

import Foundation

enum HTTPHeaderField: String {
    case accept = "Accept"
    case authorization = "Authorization"
    case contentType = "Content-Type"
    case userAgent = "User-Agent"
}

struct URLFactory {
    let scheme: String
    let host: String
    let defaultHeaders: [String: String]
    private let defaultScheme = "https"
    
    init(scheme: String? = nil, host: String, defaultHeaders: [String: String] = [:]) {
        self.scheme = scheme ?? defaultScheme
        self.host = host
        self.defaultHeaders = defaultHeaders
    }
    
    func makeRequest(path: String = "/", httpMethod: HTTPMethod = .get, queryItems: [URLQueryItem]? = nil, httpBody: Data? = nil) -> URLRequest {
        let url = makeURL(path: path, queryItems: queryItems)
        var request = URLRequest(url: url)
        request.httpBody = httpBody
        request.httpMethod = httpMethod.rawValue
        
        for header in defaultHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
//        request.addValue("application/json", forHTTPHeaderField: HTTPHeaders.accept.rawValue)
//        request.addValue("application/json", forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        return request
    }
    
    private func makeURL(path: String, queryItems: [URLQueryItem]?) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        guard let url = components.url else { fatalError("Unable to create URL with path: \(path)") }
        return url
    }
}
