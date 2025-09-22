//
//  ModernCoffeeCard.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct ModernCoffeeCard: View {
    let shop: CoffeeShop
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var isPressed = false
    @State private var showDetails = false
    @Environment(\.colorScheme) var colorScheme
    
    let coffeeIcons = [
        "cup.and.saucer.fill",
        "mug.fill",
        "leaf.fill",
        "drop.fill",
        "flame.fill",
        "heart.fill"
    ]
    
    private func randomIcon() -> String {
        coffeeIcons.randomElement() ?? "cup.and.saucer.fill"
    }
    
    private var isLiked: Bool {
        viewModel.isFavorite(shop)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.brown.opacity(0.4),
                                Color.brown.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        VStack(spacing: 10) {
                            Image(systemName: randomIcon())
                                .font(.system(size: 40))
                                .foregroundStyle(.brown)
                            
                            Text(shop.name.prefix(1).uppercased())
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.brown)
                                .opacity(0.8)
                        }
                    }
                
                likeButton
                    .buttonStyle(BorderlessButtonStyle())
                    .zIndex(1)
            }
            .frame(height: 140)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shop.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Label {
                        Text(String(format: "%.1f", shop.rating))
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                    
                    Label {
                        Text(String(format: "%.1f km", shop.distance))
                    } icon: {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.brown)
                    }
                }
                .font(.caption)
            }
            .padding(.horizontal, 8)
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            hapticFeedback()
            withAnimation {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    showDetails = true
                }
            }
        }
        .sheet(isPresented: $showDetails) {
            NavigationStack {
                CoffeeShopDetailView(shop: shop, viewModel: viewModel)
            }
        }
    }
    
    private var likeButton: some View {
        Button(action: {
            hapticFeedback()
            viewModel.toggleFavorite(shop)
        }) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isLiked ? .red : .white)
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .scaleEffect(isLiked ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked)
        .padding(8)
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
