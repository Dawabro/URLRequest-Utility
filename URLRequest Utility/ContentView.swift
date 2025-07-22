//
//  ContentView.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/14/25.
//

import SwiftUI

struct ContentView: View {
    @Bindable var model: ContentViewModel
    @State private var showNewHostSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(model.hosts) { host in
                        Button {
                            model.selectedHost = host
                        } label: {
                            VStack {
                                HostCell(host: host)
                                Divider()
                            }
                        }
                    }
                }
                .padding(.leading)
            }
            .scrollBounceBehavior(.basedOnSize)
            .sheet(isPresented: $showNewHostSheet) {
                AddNewHostSheet(title: "New Host Address", addAddressAction: model.addNewHost)
                    .padding(.horizontal)
                    .presentationDetents([.height(260)])
            }
            .navigationTitle("Hosts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("add", systemImage: "plus", role: .none) {
                        showNewHostSheet = true
                    }
                }
            }
            .navigationDestination(item: $model.selectedHost) { selectedHost in
                HostDetails(host: selectedHost, model: model)
            }
        }
        .task {
            await model.loadHosts()
        }
    }
}

fileprivate struct HostCell: View {
    let host: HostModel
    
    var body: some View {
        Text(host.address)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.blue.opacity(0.2))
            }
    }
}

#Preview {
    ContentView(model: ContentViewModel.mock)
}

struct MockData {
    
    static var hosts: [HostModel] = [
        HostModel(address: "icanhazdadjoke.com", endpoints: jokeEndpoints),
        HostModel(address: "apple.com")
    ]
    
    static let jokeHostModel: HostModel = HostModel(address: "icanhazdadjoke.com",
                                                    defaultHeaders: [HeaderModel(field: .accept, value: "application/json"),
                                                                     HeaderModel(field: .contentType, value: "application/json"),
                                                                     HeaderModel(field: .authorization, value: "super-secret-token-here")
                                                                    ],
                                                    endpoints: jokeEndpoints)
    
    static var jokeEndpoints: [EndpointModel] = [
        EndpointModel(path: "/", label: "Random Joke"),
        EndpointModel(path: "/search", label: "Search for Joke", queryItems: [QueryItemModel(name: "term", value: "teacher")])
    ]
}

struct AppLifecycleObserver: ViewModifier {
    let onBackgroundOrTerminate: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                Task {
                    await onBackgroundOrTerminate()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                Task {
                    await onBackgroundOrTerminate()
                }
            }
    }
}

extension View {
    func onAppBackgroundOrTerminate(perform action: @escaping () async -> Void) -> some View {
        modifier(AppLifecycleObserver(onBackgroundOrTerminate: action))
    }
}
