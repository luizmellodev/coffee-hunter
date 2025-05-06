//
//  FavoritesView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit

struct FavoritesView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var selectedShop: MKMapItem? = nil
    @State private var showDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.dataManager.favorites.isEmpty {
                    emptyStateView
                } else {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.dataManager.favorites, id: \.self) { shop in
                            FavoriteCard(shop: shop, viewModel: viewModel)
                                .onTapGesture {
                                    selectedShop = shop
                                    showDetail = true
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Favorites")
            .sheet(isPresented: $showDetail) {
                if let shop = selectedShop {
                    NavigationStack {
                        CoffeeShopDetailView(shop: shop, viewModel: viewModel)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No favorites yet")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Tap the heart icon on any coffee shop to add it to your favorites")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 100)
    }
}
