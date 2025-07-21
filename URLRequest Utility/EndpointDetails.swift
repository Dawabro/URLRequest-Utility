//
//  EndpointDetails.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/14/25.
//

import SwiftUI

struct EndpointDetails: View {
    let endpoint: EndpointModel
    @State private var selectedQuery: QueryItemModel?
    @State private var selectedResponse: RequestResponse?
    @State private var showAddQuerySheet = false
    @State private var showClearResponsesAlert = false
    @State private var showDeleteEndpointAlert = false
    @Environment(ContentViewModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            QueryStack(queries: endpoint.queryItems, selectedQuery: $selectedQuery, addQueryAction: { showAddQuerySheet = true })
            
            VStack {
                HStack {
                    Text("Responses:")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("Clear") {
                        showClearResponsesAlert = true
                    }
                    .opacity(endpoint.responses.isEmpty ? 0 : 1)
                    .disabled(endpoint.responses.isEmpty)
                }
                
                if endpoint.responses.isEmpty {
                    Text("No responses")
                        .padding(.vertical)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(endpoint.responses) { response in
                                VStack(alignment: .trailing, spacing: 5) {
                                    Text("\(response.date.formatted())")
                                        .font(.caption)
                                    
                                    Button {
                                        selectedResponse = response
                                    } label: {
                                        HStack {
                                            Text("\(response.statusCode)")
                                            Spacer()
                                            Text("\(response.data.count) bytes")
                                        }
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 4)
                                                .foregroundStyle(statusCodeColor(response.statusCode).opacity(0.3))
                                        }
                                    }
                                    
                                    Divider()
                                }
                            }
                        }
                        .padding(.leading)
                    }
                }
            }
            
            Spacer()
            
            Button("Send Request") {
                Task {
                    await model.sendRequest(endpoint: endpoint)
                }
            }
            .disabled(model.isSendingRequest)
        }
        .padding(.top)
        .padding(.horizontal)
        .sheet(isPresented: $showAddQuerySheet) {
            AddQuerySheet(addQueryAction: model.addQueryItem)
                .padding(.horizontal)
                .presentationDetents([.height(330)])
        }
        .sheet(item: $selectedQuery, content: { query in
            UpdateQuerySheet(currentQuery: query, updateQueryAction: model.updateQueryItem, deleteQueryAction: model.deleteQueryItem)
                .padding(.horizontal)
                .presentationDetents([.height(330)])
        })
        .sheet(item: $selectedResponse, content: { response in
            ScrollView {
                VStack {
                    Text(prettyPrintedJSONString(from: response.data) ?? "No JSON data")
                        .textSelection(.enabled)
                }
                .padding()
            }
        })
        .alert("Clear Responses", isPresented: $showClearResponsesAlert) {
            Button(role: .destructive) {
                model.removeResponses(for: endpoint)
            } label: {
                Text("Clear")
            }
        }
        .alert("Delete Endpoint: \(endpoint.path)", isPresented: $showDeleteEndpointAlert) {
            Button(role: .destructive) {
                model.deleteEndpoint(endpoint)
                dismiss()
            } label: {
                Text("Delete")
            }
        }
        .alert("Error", isPresented: Binding(
                    get: { model.requestError != nil },
                    set: { newValue in
                        if !newValue {
                            model.requestError = nil
                        }
                    }
                ), presenting: model.requestError) { error in
                    Button("OK", role: .cancel) {
                        model.requestError = nil
                    }
                } message: { error in
                    Text(error.localizedDescription)
                }
        .navigationTitle("\(endpoint.httpMethod.rawValue) \(endpoint.path)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("delete", systemImage: "trash", role: .destructive) {
                    showDeleteEndpointAlert = true
                }
            }
        }
    }
    
    private func statusCodeColor(_ statusCode: Int) -> Color {
        switch statusCode {
        case 100..<200: return .blue
        case 200..<300: return .green
        case 300..<400: return .gray
        case 400..<500: return .orange
        default: return .red
        }
    }
    
    func prettyPrintedJSONString(from data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            return String(data: prettyData, encoding: .utf8)
        } catch {
            print("Failed to pretty-print JSON:", error)
            return String(data: data, encoding: .utf8)
        }
    }
}

fileprivate struct QueryStack: View {
    let queries: [QueryItemModel]
    @Binding var selectedQuery: QueryItemModel?
    let addQueryAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Query Items:")
                    .font(.headline)
                
                Spacer()
                
                Button("Add Query") {
                    addQueryAction()
                }
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(queries) { query in
                        Button {
                            selectedQuery = query
                        } label: {
                            QueryCell(model: query)
                        }
                    }
                }
                .frame(minHeight: 35)
            }
        }
    }
}

fileprivate struct QueryCell: View {
    let model: QueryItemModel
    
    var body: some View {
        HStack {
            Text("\(model.name)=")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("\(model.value)")
                .font(.subheadline)
                .foregroundStyle(.red)
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

fileprivate struct AddQuerySheet: View {
    let addQueryAction: (String, String) async -> Void
    @State private var name = ""
    @State private var value = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Button(role: .cancel) {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            Spacer()
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Name")
                        .font(.callout)
                    
                    TextField("Query Name", text: $name)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(Color.gray.opacity(0.1))
                        }
                }
                
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Value")
                        .font(.callout)
                    
                    TextField("Query Value", text: $value)
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
            
            Spacer()
            
            Button("Add Query") {
                Task {
                    await addQueryAction(name, value)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty || value.isEmpty)
        }
        .padding(.top)
    }
}

fileprivate struct UpdateQuerySheet: View {
    let currentQuery: QueryItemModel
    let updateQueryAction: (QueryItemModel, QueryItemModel) -> Void
    let deleteQueryAction: (QueryItemModel) -> Void
    @State private var name = ""
    @State private var value = ""
    @State private var disabled: Bool = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button(role: .none) {
                    disabled.toggle()
                } label: {
                    Text(disabled ? "Enable" : "Disable")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(role: .destructive) {
                    deleteQueryAction(currentQuery)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                }
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Name")
                        .font(.callout)
                    
                    TextField("Query Name", text: $name)
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
                    
                    TextField("Query Value", text: $value)
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
            
            Spacer()
            
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Update") {
                    updateQueryAction(currentQuery, QueryItemModel(name: name, value: value, disabled: disabled))
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || value.isEmpty)
            }
        }
        .padding(.top)
        .onAppear {
            name = currentQuery.name
            value = currentQuery.value
            disabled = currentQuery.disabled
        }
    }
}

#Preview {
    NavigationStack {
        EndpointDetails(endpoint: MockData.jokeEndpoints.last!)
            .environment(ContentViewModel.mock)
    }
}
