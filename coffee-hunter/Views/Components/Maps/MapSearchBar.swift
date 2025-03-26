//
//  MapSearchBar.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//


import SwiftUI

struct MapSearchBar: View {
    @Binding var searchText: String
    @Binding var showSearch: Bool
    let onSearch: (String) -> Void
    
    var body: some View {
        HStack {
            TextField("Search location", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .onChange(of: searchText) { _, newValue in
                    onSearch(newValue)
                }
            
            Button(action: { withAnimation { showSearch = false } }) {
                Text("Cancel")
                    .foregroundColor(.brown)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}