//
//  StorageManager.swift
//  Space Traders iOS
//
//  Created by David Brown on 3/30/24.
//

import Foundation

enum StorageLocation: String {
    case storedHosts
}

protocol StorageManaging: Sendable {
    func save<T: Codable & Sendable>(value: T, to location: StorageLocation) async
    func load<T: Codable & Sendable>(from location: StorageLocation) async -> T?
    func erase(from location: StorageLocation) async
}

actor StorageManager: StorageManaging {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func save<T: Codable>(value: T, to location: StorageLocation) {
        guard let data = try? encoder.encode(value) else { return }
        try! data.write(to: urlForStorageLocation(location))
    }
    
    func load<T: Codable & Sendable>(from location: StorageLocation) -> T? {
        guard let data = try? Data(contentsOf: urlForStorageLocation(location)) else { return nil }
        return try! decoder.decode(T.self, from: data)
    }
    
    func erase(from location: StorageLocation) {
        try? FileManager.default.removeItem(at: urlForStorageLocation(location))
    }
    
    private func urlForStorageLocation(_ location: StorageLocation) -> URL {
        URL.documentsDirectory.appendingPathComponent(location.rawValue)
    }
}

actor MockStorageManager: StorageManaging {
    private var mockStorage = [StorageLocation: Codable]()
    
    init() {
        
    }
    
    func save<T: Codable>(value: T, to location: StorageLocation) {
        mockStorage[location] = value
    }
    
    func load<T: Codable & Sendable>(from location: StorageLocation) -> T? {
        mockStorage[location] as? T
    }
    
    func erase(from location: StorageLocation) {
        mockStorage.removeValue(forKey: location)
    }
}
