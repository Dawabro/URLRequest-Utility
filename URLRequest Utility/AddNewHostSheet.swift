//
//  AddNewHostSheet.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/14/25.
//

import SwiftUI

struct AddNewHostSheet: View {
    let title: String
    let addAddressAction: (String, String?) -> Void
    @State private var newAddress: String = ""
    @State private var label: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Address")
                        .font(.callout)
                    
                    TextField(title, text: $newAddress)
                        .keyboardType(.URL)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(Color.gray.opacity(0.1))
                        }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Label")
                        .font(.callout)
                    
                    TextField("Label (Optional)", text: $label)
                        .keyboardType(.alphabet)
                        .autocorrectionDisabled(true)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(Color.gray.opacity(0.1))
                        }
                }
            }
            
            HStack(spacing: 20) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Add") {
                    addAddressAction(newAddress, label.isEmpty ? nil : label)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newAddress.isEmpty)
            }
        }
    }
}

#Preview {
    AddNewHostSheet(title: "Add Address", addAddressAction: { _,_ in })
}
