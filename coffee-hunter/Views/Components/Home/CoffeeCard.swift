//
//  CoffeeCard.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 26/03/25.
//


import SwiftUI

struct CoffeeCard: View {
    let shop: CoffeeShop
    let viewModel: CoffeeHunterViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.brown.opacity(0.15))
                    .frame(height: 120)
                    .overlay {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.brown.opacity(0.4))
                    }
                
                Button {
                    viewModel.toggleFavorite(shop)
                } label: {
                    Image(systemName: viewModel.isFavorite(shop) ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite(shop) ? .red : .gray)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shop.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", shop.rating))
                    
                    Spacer()
                    
                    Image(systemName: "location.fill")
                        .foregroundColor(.brown)
                    Text(String(format: "%.1f km", shop.distance))
                }
                .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 200)
        .background(Color(.systemBackground).opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .onTapGesture {
            viewModel.navigateToMapWithShop(shop)
        }
    }
}
