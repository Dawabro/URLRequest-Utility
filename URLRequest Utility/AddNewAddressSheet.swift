//
//  AddNewAddressSheet.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/14/25.
//

import SwiftUI

struct AddNewAddressSheet: View {
    let title: String
    let addAddressAction: (String) async -> Void
    @State private var newAddress: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            TextField(title, text: $newAddress)
                .keyboardType(.URL)
                .autocorrectionDisabled(true)
            
            Button("Add") {
                Task {
                    await addAddressAction(newAddress)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    AddNewAddressSheet(title: "Add Address", addAddressAction: { _ in })
}
