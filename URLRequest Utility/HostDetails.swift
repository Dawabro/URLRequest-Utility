//
//  HostDetails.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/14/25.
//

import SwiftUI

struct HostDetails: View {
    let host: HostModel
    @Bindable var model: ContentViewModel
    @State private var showAddHeaderSheet: Bool = false
    @State private var selectedHeader: HeaderModel?
    @State private var showAddEndpointSheet: Bool = false
    @State private var showDeleteHostAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 25) {
            VStack {
                HeaderStack(headers: host.defaultHeaders, selectedHeader: $selectedHeader, addHeaderAction: { showAddHeaderSheet = true })
                Divider()
            }
            
            VStack {
                HStack {
                    Text("Endpoints:")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("Add Endpoint") {
                        showAddEndpointSheet = true
                    }
                }
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(host.endpoints) { endpoint in
                            Button {
                                model.selectedEndpoint = endpoint
                            } label: {
                                VStack {
                                    EndpointCell(endpoint: endpoint)
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .padding(.top)
        .padding(.horizontal)
        .sheet(isPresented: $showAddEndpointSheet) {
            AddNewEndpointSheet(title: "New Endpoint Address", addEndpointAction: model.addEndpoint)
                .padding(.horizontal)
                .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $showAddHeaderSheet) {
            AddHeaderSheet(addHeaderAction: model.addHeader)
                .padding(.horizontal)
                .presentationDetents([.height(260)])
        }
        .sheet(item: $selectedHeader, content: { header in
            UpdateHeaderSheet(currentHeader: header, updateHeaderAction: model.updateHeader(_:to:), deleteHeaderAction: model.deleteHeader(_:))
                .padding(.horizontal)
                .presentationDetents([.height(320)])
        })
        .alert("Delete Host: \(host.address)", isPresented: $showDeleteHostAlert) {
            Button(role: .destructive) {
                model.deleteHost(host)
                dismiss()
            } label: {
                Text("Delete")
            }
        }
        .navigationTitle(host.address)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("add", systemImage: "trash", role: .destructive) {
                    showDeleteHostAlert = true
                }
            }
        }
        .navigationDestination(item: $model.selectedEndpoint) { selectedEndpoint in
            EndpointDetails(endpoint: selectedEndpoint)
                .environment(model)
        }
    }
}

fileprivate struct HeaderStack: View {
    let headers: [HeaderModel]
    @Binding var selectedHeader: HeaderModel?
    let addHeaderAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Default Headers:")
                    .font(.headline)
                
                Spacer()
                
                Button("Add Header") {
                    addHeaderAction()
                }
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(headers) { header in
                        Button {
                            selectedHeader = header
                        } label: {
                            HeaderCell(model: header)
                        }
                    }
                }
                .frame(minHeight: 35)
            }
        }
    }
}

fileprivate struct HeaderCell: View {
    let model: HeaderModel
    
    var body: some View {
        HStack {
            Text("\(model.key):")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("\(model.value)")
                .font(.subheadline)
                .foregroundStyle(model.disabled ? Color.gray : .red)
        }
        .padding(8)
        .opacity(model.disabled ? 0.3 : 1)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.gray.opacity(0.2))
        }
        .transition(.opacity.animation(.easeInOut(duration: 1)))
    }
}

fileprivate struct AddHeaderSheet: View {
    let addHeaderAction: (String, String) -> Void
    @State private var key = ""
    @State private var value = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Key")
                        .font(.callout)
                    
                    TextField("Header Key", text: $key)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(Color.gray.opacity(0.1))
                        }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Value")
                        .font(.callout)
                    
                    TextField("Header Value", text: $value)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(Color.gray.opacity(0.1))
                        }
                }
            }
            .fontDesign(.monospaced)
            .keyboardType(.alphabet)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            
            HStack(spacing: 30) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Add Header") {
                    addHeaderAction(key, value)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
    }
}

fileprivate struct UpdateHeaderSheet: View {
    let currentHeader: HeaderModel
    let updateHeaderAction: (HeaderModel, HeaderModel) -> Void
    let deleteHeaderAction: (HeaderModel) -> Void
    @State private var key = ""
    @State private var value = ""
    @State private var disabled: Bool = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button(role: .none) {
                    disabled.toggle()
                } label: {
                    Text(disabled ? "Enable" : "Disable")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(role: .destructive) {
                    deleteHeaderAction(currentHeader)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                }
            }
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Key")
                        .font(.callout)
                    
                    TextField("Header Key", text: $key)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(Color.gray.opacity(0.1))
                        }
                        .opacity(disabled ? 0.4 : 1)
                        .disabled(disabled)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Value")
                        .font(.callout)
                    
                    TextField("Header Value", text: $value)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(Color.gray.opacity(0.1))
                        }
                        .opacity(disabled ? 0.4 : 1)
                        .disabled(disabled)
                }
            }
            .fontDesign(.monospaced)
            .keyboardType(.alphabet)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            
            HStack(spacing: 30) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Update") {
                    updateHeaderAction(currentHeader, HeaderModel(key: key, value: value, disabled: disabled))
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .onAppear {
            key = currentHeader.key
            value = currentHeader.value
            disabled = currentHeader.disabled
        }
    }
}

#Preview {
    @Previewable @State var model = ContentViewModel.mock
    
    NavigationStack {
        HostDetails(host: MockData.jokeHostModel, model: model)
    }
}
