//
//  TourCard.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct TourCard: View {
    let tour: CoffeeTour
    let isPurchased: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with duration
            HStack {
                Label(tour.duration.displayName, systemImage: "clock.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.brown)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.brown.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
                
                if isPurchased {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Purchased")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.green)
                } else if let price = tour.price {
                    Text("R$ \(String(format: "%.2f", price))")
                        .font(.headline)
                        .foregroundColor(.brown)
                }
            }
            
            // Tour name
            Text(tour.name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Description
            Text(tour.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Stats
            HStack(spacing: 16) {
                Label(
                    "\(String(format: "%.1f", tour.estimatedDistance)) km",
                    systemImage: "map.fill"
                )
                .font(.caption)
                .foregroundColor(.secondary)
                
                Label(
                    tour.difficulty.rawValue,
                    systemImage: tour.difficulty.icon
                )
                .font(.caption)
                .foregroundColor(.secondary)
                
                if !tour.stops.isEmpty {
                    Label(
                        "\(tour.stops.count) stop\(tour.stops.count == 1 ? "" : "s")",
                        systemImage: "pin.fill"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPurchased ? Color.green.opacity(0.3) : Color(.separator), lineWidth: 1)
        )
    }
}

