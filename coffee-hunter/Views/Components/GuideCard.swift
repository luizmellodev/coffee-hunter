//
//  GuideCard.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct GuideCard: View {
    let guide: ContentGuide
    let isPurchased: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(categoryColor(guide.category).opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: guide.category.icon)
                    .font(.title2)
                    .foregroundColor(categoryColor(guide.category))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(guide.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                }
                
                Text(guide.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Label("\(guide.estimatedReadingTime) min", systemImage: "book.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if guide.isPremium {
                        if isPurchased {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Purchased")
                            }
                            .font(.caption2)
                            .foregroundColor(.green)
                        } else if let price = guide.price {
                            Text("R$ \(String(format: "%.2f", price))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    } else {
                        Text("FREE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isPurchased ? 
                        Color.green.opacity(0.3) : 
                        (guide.isPremium ? Color.orange.opacity(0.3) : Color.green.opacity(0.3)),
                    lineWidth: 1
                )
        )
    }
    
    private func categoryColor(_ category: ContentGuide.GuideCategory) -> Color {
        switch category {
        case .basics: return .blue
        case .equipment: return .purple
        case .brewing: return .brown
        case .roasting: return .orange
        case .grinding: return .gray
        }
    }
}

