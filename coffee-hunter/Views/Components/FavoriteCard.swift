//
//  FavoriteCard.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//


import SwiftUI

struct FavoriteCard: View {
    let shop: CoffeeShop
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.brown.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.title2)
                        .foregroundColor(.brown)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shop.name)
                    .font(.headline)
                
                Text(shop.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label(String(format: "%.1f", shop.rating), systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
            
            Spacer()
            
            Button(action: { showingDeleteConfirmation = true }) {
                Image(systemName: "heart.slash.fill")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .alert("Remove from Favorites", isPresented: $showingDeleteConfirmation) {
            Button("Remove", role: .destructive) {
                withAnimation {
                    viewModel.toggleFavorite(shop)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove \(shop.name) from your favorites?")
        }
    }
}
