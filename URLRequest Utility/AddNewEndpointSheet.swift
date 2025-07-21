//
//  AddNewEndpointSheet.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/21/25.
//

import SwiftUI

struct AddNewEndpointSheet: View {
    let title: String
    let addEndpointAction: (HTTPMethod, String, String?) -> Void
    @State private var newAddress: String = ""
    @State private var label: String = ""
    @State private var httpMethod: HTTPMethod = .get
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                VStack(spacing: 2) {
                    Text("HTTP Method")
                        .font(.footnote)
                    
                    Picker("HTTP Method", selection: $httpMethod) {
                        ForEach(HTTPMethod.allCases, id: \.self) { method in
                            Text(method.rawValue)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Address")
                        .font(.callout)
                    
                    TextField(title, text: $newAddress)
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
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(Color.gray.opacity(0.1))
                        }
                }
            }
            .keyboardType(.URL)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            
            HStack(spacing: 20) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Add") {
                    addEndpointAction(httpMethod, newAddress, label.isEmpty ? nil : label)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newAddress.isEmpty)
            }
        }
    }
}

#Preview {
    AddNewEndpointSheet(title: "Add New Endpoint", addEndpointAction: { _,_,_ in })
}
