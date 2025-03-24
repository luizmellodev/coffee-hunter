//
//  HomeView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var selectedSection = 0
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    HStack(spacing: 30) {
                        sectionButton(title: "Popular", tag: 0, icon: "star.fill")
                        sectionButton(title: "Nearby", tag: 1, icon: "location.fill")
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ZStack {
                        if selectedSection == 0 {
                            popularCafesGrid
                                .transition(AnyTransition.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else {
                            nearbyCafesGrid
                                .transition(AnyTransition.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedSection)
                }
                .padding(.vertical)
            }
            .navigationTitle("Coffee Hunter")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func sectionButton(title: String, tag: Int, icon: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(selectedSection == tag ? .brown : .secondary)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(selectedSection == tag ? .primary : .secondary)
            }
            
            if selectedSection == tag {
                Capsule()
                    .fill(Color.brown)
                    .frame(height: 3)
                    .matchedGeometryEffect(id: "section", in: animation)
                    .transition(.scale)
            } else {
                Capsule()
                    .fill(Color.clear)
                    .frame(height: 3)
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedSection = tag
            }
        }
    }
    
    private var popularCafesGrid: some View {
        let shops = viewModel.coffeeShopService.coffeeShops.sorted { $0.rating > $1.rating }
        return cafesGrid(shops: shops)
    }
    
    private var nearbyCafesGrid: some View {
        let shops = viewModel.coffeeShopService.coffeeShops.sorted { $0.distance < $1.distance }
        return cafesGrid(shops: shops)
    }
    
    private func cafesGrid(shops: [CoffeeShop]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(shops) { shop in
                ModernCoffeeCard(shop: shop, viewModel: viewModel)
                    .frame(height: 220)
            }
        }
        .padding(.horizontal)
    }
}
