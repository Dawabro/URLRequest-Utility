//
//  URLRequest_UtilityApp.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/14/25.
//

import SwiftUI

@main
struct URLRequest_UtilityApp: App {
    @State private var viewModel = ContentViewModel(requestHandler: RequestHandler(), storageManager: StorageManager())
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: viewModel)
                .onAppBackgroundOrTerminate(perform: viewModel.saveData)
        }
    }
}
