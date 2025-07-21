//
//  RequestHandler.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/14/25.
//

import Foundation

struct RequestResponse: Identifiable, Equatable, Codable {
    let id: UUID
    let data: Data
    let statusCode: Int
    let date: Date
    
    init(data: Data, statusCode: Int, date: Date = Date()) {
        self.id = UUID()
        self.data = data
        self.statusCode = statusCode
        self.date = date
    }
}

protocol RequestHandling {
    func makeRequest(host: String, headers: [String: String], path: String, httpMethod: HTTPMethod, queryItems: [URLQueryItem]?) async throws -> RequestResponse
}

final class RequestHandler: RequestHandling {
    
    func makeRequest(host: String, headers: [String: String] = [:], path: String, httpMethod: HTTPMethod, queryItems: [URLQueryItem]?) async throws -> RequestResponse {
        let urlFactory = URLFactory(host: host, defaultHeaders: headers)
        let request = urlFactory.makeRequest(path: path, httpMethod: httpMethod, queryItems: queryItems)
        let response = try await URLSession.shared.data(for: request)
        let responseDate = response.0
        let responseStatusCode = (response.1 as? HTTPURLResponse)?.statusCode ?? 418
        print("received response of length \(response.0.count)")
        return RequestResponse(data: responseDate, statusCode: responseStatusCode)
    }
}

struct MockRequestHandler: RequestHandling {
    
    func makeRequest(host: String, headers: [String: String], path: String, httpMethod: HTTPMethod, queryItems: [URLQueryItem]?) async throws -> RequestResponse {
        print("sending request to \(host)\(path)")
        return RequestResponse(data: Data(), statusCode: 418)
    }
}
