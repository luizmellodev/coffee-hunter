//
//  GuideDetailView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct GuideDetailView: View {
    let guide: ContentGuide
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showPurchaseAlert = false
    @State private var isPurchasing = false
    
    private var canAccess: Bool {
        viewModel.canAccessGuide(guide)
    }
    
    private var isPurchased: Bool {
        viewModel.hasPurchasedGuide(guide)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                // Guide info
                guideInfoSection
                
                // Content
                contentSection
                
                // Purchase button (if needed)
                if guide.isPremium && !isPurchased {
                    purchaseSection
                }
            }
            .padding()
        }
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Purchase Guide", isPresented: $showPurchaseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Purchase R$ \(String(format: "%.2f", guide.price ?? 0))") {
                purchaseGuide()
            }
        } message: {
            Text("Would you like to purchase the guide \"\(guide.title)\"? This purchase supports the ongoing development of quality content.")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category badge
                HStack(spacing: 6) {
                    Image(systemName: guide.category.icon)
                    Text(guide.category.rawValue)
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(categoryColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(categoryColor.opacity(0.1))
                .clipShape(Capsule())
                
                Spacer()
                
                // Status badge
                if !guide.isPremium {
                    Text("FREE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                } else if isPurchased {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Adquirido")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
                } else {
                    Text("PREMIUM")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            
            Text(guide.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var guideInfoSection: some View {
        HStack(spacing: 20) {
            infoItem(
                icon: "book.fill",
                value: "\(guide.estimatedReadingTime) min",
                label: "Leitura",
                color: categoryColor
            )
            
            infoItem(
                icon: "person.fill",
                value: guide.author,
                label: "Autor",
                color: .blue
            )
            
            infoItem(
                icon: "calendar",
                value: guide.publishedDate.formatted(date: .abbreviated, time: .omitted),
                label: "Publicado",
                color: .green
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func infoItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Content")
                .font(.title3)
                .fontWeight(.bold)
            
            if canAccess {
                // Full content with proper markdown rendering
                Text(try! AttributedString(markdown: guide.content))
                    .font(.body)
                    .foregroundColor(.primary)
            } else {
                // Preview only
                VStack(alignment: .leading, spacing: 12) {
                    Text(try! AttributedString(markdown: String(guide.content.prefix(300))))
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text("...")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        Text("Premium Content")
                            .font(.headline)
                        
                        Text("Purchase this guide to access full content")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Tags
            if !guide.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(guide.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top)
            }
        }
    }
    
    private var purchaseSection: some View {
        VStack(spacing: 16) {
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Purchase this guide")
                            .font(.headline)
                        
                        Text("Permanent access to full content")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("R$ \(String(format: "%.2f", guide.price ?? 0))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                }
                
                Button {
                    showPurchaseAlert = true
                } label: {
                    HStack {
                        Image(systemName: "cart.fill")
                        Text("Purchase Guide")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isPurchasing)
                
                // Info about cafeza.club
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("Much free content available at")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Link("cafeza.club", destination: URL(string: "https://cafeza.club")!)
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var categoryColor: Color {
        switch guide.category {
        case .basics: return .blue
        case .equipment: return .purple
        case .brewing: return .brown
        case .roasting: return .orange
        case .grinding: return .gray
        }
    }
    
    private func purchaseGuide() {
        isPurchasing = true
        
        viewModel.purchaseGuide(guide) { success in
            isPurchasing = false
            if success {
                // Show success feedback
            }
        }
    }
}

