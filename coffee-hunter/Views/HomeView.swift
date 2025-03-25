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
    @State private var isPickingCoffee = false
    @State private var rotation: Double = 0
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    // Coffee Picker Button
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            isPickingCoffee = true
                            rotation += 360
                        }
                    } label: {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 24))
                                .rotationEffect(.degrees(rotation))
                            
                            Text("Escolha meu café")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.brown, Color(red: 0.4, green: 0.2, blue: 0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .brown.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                        .sheet(isPresented: $isPickingCoffee) {
                            RandomCoffeePickerView(viewModel: viewModel)
                        }
                    }
                    .disabled(isPickingCoffee)
                    
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
