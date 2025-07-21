//
//  EndpointCell.swift
//  URLRequest Utility
//
//  Created by David Brown on 7/14/25.
//

import SwiftUI

struct EndpointCell: View {
    let endpoint: EndpointModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let label = endpoint.label {
                Text(label)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
            
            Text("\(endpoint.httpMethod.rawValue): \(endpoint.path)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(Color.blue.opacity(0.2))
                }
        }
        .fontDesign(.monospaced)
    }
}

#Preview {
    EndpointCell(endpoint: MockData.jokeEndpoints.first!)
}
