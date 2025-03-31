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
                    
                    Group {
                        CoffeeShopSection(
                            viewModel: viewModel,
                            title: "Popular picks",
                            icon: "star.fill",
                            iconColor: .yellow,
                            shops: Array(viewModel.coffeeShopService.coffeeShops
                                .sorted { $0.rating > $1.rating }),
                            showContent: $showContent
                        )
                        
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
                        
                        CoffeeShopSection(
                            viewModel: viewModel,
                            title: "Around you",
                            icon: "location.fill",
                            iconColor: .brown,
                            shops: Array(viewModel.coffeeShopService.coffeeShops
                                .sorted { $0.distance < $1.distance }),
                            showContent: $showContent
                        )
                        
                        if !viewModel.dataManager.favorites.isEmpty {
                            CoffeeShopSection(
                                viewModel: viewModel,
                                title: "Your favorites",
                                icon: "heart.fill",
                                iconColor: .red,
                                shops: Array(viewModel.dataManager.favorites),
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
            .refreshable(action: {
                viewModel.refreshLocation()

            })
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showContent = true
            }
        }
    }
}
