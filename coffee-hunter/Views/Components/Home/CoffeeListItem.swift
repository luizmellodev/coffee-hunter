//
//  CoffeeListItem.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 26/03/25.
//

import SwiftUI
import MapKit

struct CoffeeListItem: View {
    @Binding var showAll: Bool
    let shop: MKMapItem
    let viewModel: CoffeeHunterViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(shop.name ?? "Unknown")
                    .font(.headline)
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", CoffeeShopData.shared.metadata(for: shop).rating))
                    Text("•")
                    Image(systemName: "location.fill")
                        .foregroundColor(.brown)
                    Text(String(format: "%.1f km", CoffeeShopData.shared.metadata(for: shop).distance))
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
