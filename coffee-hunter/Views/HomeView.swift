//
//  HomeView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var isPickingCoffee = false
    @State private var rotation: Double = 0
    @State private var showingAllPopular = false
    @State private var showingAllNearby = false
    @State private var showingAllFavorites = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    // Greeting Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hello,")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Coffee Hunter!")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    
                    // Random Coffee Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Discover New Coffee")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                isPickingCoffee = true
                                rotation += 360
                            }
                        } label: {
                            HStack(spacing: 15) {
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 40))
                                    .rotationEffect(.degrees(rotation))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Random Coffee")
                                        .font(.headline)
                                    Text("Let us pick a coffee shop for you")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.7, green: 0.5, blue: 0.3),
                                                Color(red: 0.5, green: 0.3, blue: 0.2)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $isPickingCoffee) {
                            RandomCoffeePickerView(viewModel: viewModel)
                        }
                    }
                    
                    // Coffee Sections with navigation
                    CoffeeSection(
                        title: "Popular Coffees",
                        icon: "star.fill",
                        shops: viewModel.coffeeShopService.coffeeShops
                            .sorted { $0.rating > $1.rating }
                            .prefix(3),
                        viewModel: viewModel,
                        showAll: $showingAllPopular,
                        allShops: viewModel.coffeeShopService.coffeeShops
                            .sorted { $0.rating > $1.rating }
                    )
                    
                    CoffeeSection(
                        title: "Nearby Coffees",
                        icon: "location.fill",
                        shops: viewModel.coffeeShopService.coffeeShops
                            .sorted { $0.distance < $1.distance }
                            .prefix(3),
                        viewModel: viewModel,
                        showAll: $showingAllNearby,
                        allShops: viewModel.coffeeShopService.coffeeShops
                            .sorted { $0.distance < $1.distance }
                    )
                    
                    if !viewModel.dataManager.favorites.isEmpty {
                        CoffeeSection(
                            title: "Your Favorites",
                            icon: "heart.fill",
                            shops: viewModel.dataManager.favorites.prefix(3),
                            viewModel: viewModel,
                            showAll: $showingAllFavorites,
                            allShops: viewModel.dataManager.favorites
                        )
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .background(Color(.systemBackground).opacity(0.9))
        }
    }
}


