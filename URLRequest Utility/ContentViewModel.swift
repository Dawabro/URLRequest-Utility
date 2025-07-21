//
//  ContentViewModel.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/14/25.
//

import Foundation

@Observable
@MainActor
final class ContentViewModel {
    var hosts: [HostModel] = []
    var selectedHost: HostModel?
    var selectedEndpoint: EndpointModel?
    var isSendingRequest: Bool = false
    var requestError: Error?
    private let requestHandler: RequestHandling
    private let storageManager: StorageManaging
    
    init(requestHandler: RequestHandling, storageManager: StorageManaging) {
        self.requestHandler = requestHandler
        self.storageManager = storageManager
    }
    
    func loadHosts() async {
        hosts = await storageManager.load(from: .storedHosts) ?? MockData.hosts
    }
    
    func addNewHost(address: String, label: String?) {
        guard !hosts.contains(where: { $0.address == address }) else { return }
        
        let newHost = HostModel(address: address, label: label)
        hosts.append(newHost)
    }
    
    func deleteHost(_ host: HostModel) {
        guard let index = hosts.firstIndex(of: host) else { return }
        hosts.remove(at: index)
    }
    
    func addHeader(_ key: String, _ value: String) {
        guard let selectedHost else { return }
        selectedHost.defaultHeaders.append(HeaderModel(key: key, value: value))
    }
    
    func updateHeader(_ currentHeader: HeaderModel, to updatedModel: HeaderModel) {
        guard let selectedHost else { return }
        guard let index = selectedHost.defaultHeaders.firstIndex(where: { $0.id == currentHeader.id }) else { return }
        selectedHost.defaultHeaders[index] = updatedModel
    }
    
    func deleteHeader(_ header: HeaderModel) {
        guard let selectedHost else { return }
        guard let index = selectedHost.defaultHeaders.firstIndex(where: { $0.id == header.id }) else { return }
        selectedHost.defaultHeaders.remove(at: index)
    }
    
    func addEndpoint(httpMethod: HTTPMethod, endpointPath: String, label: String?) {
        guard let selectedHost, selectedHost.endpoints.allSatisfy({ $0.path != endpointPath }) else { return }
        selectedHost.endpoints.append(EndpointModel(path: endpointPath, label: label, httpMethod: httpMethod))
    }
    
    func deleteEndpoint(_ endpoint: EndpointModel) {
        guard let selectedHost, let index = selectedHost.endpoints.firstIndex(of: endpoint) else { return }
        selectedHost.endpoints.remove(at: index)
    }
    
    func addQueryItem(_ name: String, _ value: String) {
        guard let selectedEndpoint else { return }
        
        if let existingQueryItem = selectedEndpoint.queryItems.first(where: { $0.name == name }) {
            updateQueryItem(existingQueryItem, to: QueryItemModel(name: name, value: value))
        } else {
            selectedEndpoint.queryItems.append(QueryItemModel(name: name, value: value))
        }
    }
    
    func updateQueryItem(_ currentItem: QueryItemModel, to updatedModel: QueryItemModel) {
        guard let selectedEndpoint, let index = selectedEndpoint.queryItems.firstIndex(of: currentItem) else { return }
        selectedEndpoint.queryItems[index] = updatedModel
    }
    
    func deleteQueryItem(_ item: QueryItemModel) {
        guard let selectedEndpoint, let index = selectedEndpoint.queryItems.firstIndex(of: item) else { return }
        selectedEndpoint.queryItems.remove(at: index)
    }
    
    func sendRequest(endpoint: EndpointModel) async {
        guard let selectedHost else { return }
        isSendingRequest = true
        
        do {
            let headers: [String: String] = selectedHost.defaultHeaders.filter({ $0.disabled == false }).reduce(into: [:]) { $0[$1.key] = $1.value }
            let queryItems = endpoint.queryItems.filter({ $0.disabled == false}).map({ URLQueryItem(name: $0.name, value: $0.value) })
            let response = try await requestHandler.makeRequest(host: selectedHost.address, headers: headers, path: endpoint.path, httpMethod: endpoint.httpMethod, queryItems: queryItems)
            endpoint.responses.append(response)
            endpoint.responses.sort { $0.date > $1.date }
        } catch {
            requestError = error
        }
        
        isSendingRequest = false
    }
    
    func removeResponses(for endpoint: EndpointModel) {
        endpoint.responses.removeAll()
    }
    
    func saveData() async {
        await storageManager.save(value: hosts, to: .storedHosts)
        print("Data saved!")
    }
}

extension ContentViewModel {
    
    static var mock: ContentViewModel {
        ContentViewModel(requestHandler: MockRequestHandler(), storageManager: MockStorageManager())
    }
}
