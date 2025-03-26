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
    @State private var rotation = 0.0
    @State private var showingWelcome = false
    @State private var showContent = false
    @State private var cupScale = 0.8
    @State private var greetingOpacity = 0.0
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    // Animated Welcome Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hey coffee lover!")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .opacity(greetingOpacity)
                        
                        Text("Let's grab a coffee?")
                            .font(.title)
                            .fontWeight(.bold)
                            .opacity(greetingOpacity)
                    }
                    .padding(.horizontal)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8)) {
                            greetingOpacity = 1
                        }
                    }
                    
                    // Animated Coffee Discovery Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Feeling adventurous?")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                rotation += 360
                                cupScale = 1.1
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    cupScale = 1.0
                                }
                                isPickingCoffee = true
                            }
                        } label: {
                            HStack(spacing: 15) {
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 40))
                                    .rotationEffect(.degrees(rotation))
                                    .scaleEffect(cupScale)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: cupScale)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Surprise me!")
                                        .font(.headline)
                                    Text("Discover a random coffee shop")
                                        .multilineTextAlignment(.leading)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "sparkles")
                                    .font(.title2)
                                    .rotationEffect(.degrees(rotation))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.8, green: 0.6, blue: 0.4),
                                                Color(red: 0.6, green: 0.4, blue: 0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.3).opacity(0.3), radius: 10, y: 5)
                            )
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .sheet(isPresented: $isPickingCoffee) {
                            RandomCoffeePickerView(viewModel: viewModel)
                        }
                    }
                    
                    // Animated sections
                    Group {
                        PopularSection(
                            viewModel: viewModel,
                            showContent: $showContent
                        )
                        
                        NearbySection(
                            viewModel: viewModel,
                            showContent: $showContent
                        )
                        
                        if !viewModel.dataManager.favorites.isEmpty {
                            FavoritesSection(
                                viewModel: viewModel,
                                showContent: $showContent
                            )
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .background(
                Color(.systemBackground)
                    .opacity(0.95)
                    .ignoresSafeArea()
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showContent = true
            }
        }
    }
}

struct PopularSection: View {
    let viewModel: CoffeeHunterViewModel
    @Binding var showContent: Bool
    @State private var showAll = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Popular picks")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("See All") {
                    showAll = true
                }
                .font(.subheadline)
                .foregroundColor(.brown)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(viewModel.coffeeShopService.coffeeShops
                        .sorted { $0.rating > $1.rating }
                        .prefix(3))) { shop in
                        CoffeeCard(shop: shop, viewModel: viewModel)
                            .transition(.slide)
                    }
                }
                .padding(.horizontal)
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .sheet(isPresented: $showAll) {
            NavigationView {
                List(Array(viewModel.coffeeShopService.coffeeShops
                    .sorted { $0.rating > $1.rating })) { shop in
                        CoffeeListItem(showAll: $showAll, shop: shop, viewModel: viewModel)
                }
                .navigationTitle("Popular Coffee Shops")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showAll = false
                        }
                    }
                }
            }
        }
    }
}

struct NearbySection: View {
    let viewModel: CoffeeHunterViewModel
    @Binding var showContent: Bool
    @State private var showAll = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.brown)
                Text("Around you")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("See All") {
                    showAll = true
                }
                .font(.subheadline)
                .foregroundColor(.brown)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(viewModel.coffeeShopService.coffeeShops
                        .sorted { $0.distance < $1.distance }
                        .prefix(3))) { shop in
                        CoffeeCard(shop: shop, viewModel: viewModel)
                            .transition(.slide)
                    }
                }
                .padding(.horizontal)
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .sheet(isPresented: $showAll) {
            NavigationView {
                List(Array(viewModel.coffeeShopService.coffeeShops
                    .sorted { $0.distance < $1.distance })) { shop in
                        CoffeeListItem(showAll: $showAll, shop: shop, viewModel: viewModel)
                }
                .navigationTitle("Nearby Coffee Shops")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showAll = false
                        }
                    }
                }
            }
        }
    }
}

struct FavoritesSection: View {
    let viewModel: CoffeeHunterViewModel
    @Binding var showContent: Bool
    @State private var showAll = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Your favorites")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("See All") {
                    showAll = true
                }
                .font(.subheadline)
                .foregroundColor(.brown)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(viewModel.dataManager.favorites.prefix(3))) { shop in
                        CoffeeCard(shop: shop, viewModel: viewModel)
                            .transition(.slide)
                    }
                }
                .padding(.horizontal)
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .sheet(isPresented: $showAll) {
            NavigationView {
                List(Array(viewModel.dataManager.favorites)) { shop in
                    CoffeeListItem(showAll: $showAll, shop: shop, viewModel: viewModel)
                }
                .navigationTitle("Favorite Coffee Shops")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showAll = false
                        }
                    }
                }
            }
        }
    }
}
