//
//  CoffeeListItem.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 26/03/25.
//


import SwiftUI

struct CoffeeListItem: View {
    @Binding var showAll: Bool
    let shop: CoffeeShop
    let viewModel: CoffeeHunterViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(shop.name)
                    .font(.headline)
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", shop.rating))
                    Text("•")
                    Image(systemName: "location.fill")
                        .foregroundColor(.brown)
                    Text(String(format: "%.1f km", shop.distance))
                }
                .font(.caption)
            }
            
            Spacer()
            
            Button {
                viewModel.toggleFavorite(shop)
            } label: {
                Image(systemName: viewModel.isFavorite(shop) ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite(shop) ? .red : .gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.showAll = false
            viewModel.navigateToMapWithShop(shop)
        }
    }
}
