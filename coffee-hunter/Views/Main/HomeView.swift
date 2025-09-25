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
    @State private var selectedFilter = "All"
    
    private let filters = ["All", "Popular", "Nearby", "Favorites"]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    headerSection
                    quickStatsSection
                    discoveryCard
                    filterSection
                    coffeeShopsGrid
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
            .refreshable {
                viewModel.refreshLocation()
            }
            .sheet(isPresented: $isPickingCoffee) {
                RandomCoffeePickerView(viewModel: viewModel)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showContent = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
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
                .padding(.top, 10)
                
                Spacer()
                
                Button {
                    viewModel.refreshLocation()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.brown)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.separator), lineWidth: 0.5)
                        )
                }
            }
            
            if viewModel.selectedLocation != nil {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.brown)
                    Text("Showing coffee shops near \(viewModel.locationName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                greetingOpacity = 1
            }
        }
    }
    
    private var quickStatsSection: some View {
        HStack(spacing: 16) {
            statsCard(
                count: viewModel.coffeeShops.count,
                title: "Coffee Shops",
                icon: "cup.and.saucer.fill",
                color: .brown
            )
            
            statsCard(
                count: viewModel.favorites.count,
                title: "Favorites",
                icon: "heart.fill",
                color: .red
            )
            
            statsCard(
                count: viewModel.visitHistory.count,
                title: "Visited",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    private func statsCard(count: Int, title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text("\(count)")
                    .font(.headline)
                    .contentTransition(.numericText())
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
    
    private var discoveryCard: some View {
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
                    Text("Feeling adventurous?")
                        .font(.headline)
                    Text("Let us surprise you with a perfect coffee spot!")
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
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .foregroundColor(.white)
        }
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedFilter == filter ? .white : .brown)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ?
                                Color.brown :
                                Color(.secondarySystemBackground)
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var coffeeShopsGrid: some View {
        let shops = viewModel.coffeeShops
        let filteredShops: [CoffeeShop] = {
            switch selectedFilter {
            case "Popular":
                return shops.sorted { $0.rating > $1.rating }
            case "Nearby":
                return shops.sorted { $0.distance < $1.distance }
            case "Favorites":
                return viewModel.favorites
            default:
                return shops
            }
        }()
        
        return LazyVStack(spacing: 16) {
            ForEach(filteredShops) { shop in
                ModernCoffeeCard(shop: shop, viewModel: viewModel)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
}
