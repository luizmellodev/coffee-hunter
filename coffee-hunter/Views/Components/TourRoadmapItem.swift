//
//  TourRoadmapItem.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit

struct TourRoadmapItem: View {
    let stop: TourStop
    let number: Int
    let direction: RoadDirection
    let isFirstItem: Bool
    let isLastItem: Bool
    
    enum RoadDirection {
        case left
        case right
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left content
            if direction == .left {
                contentCard
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            
            // Center line with marker
            VStack(spacing: 0) {
                // Top line
                if !isFirstItem {
                    VerticalDashedLine()
                        .stroke(Color.brown.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .frame(width: 2, height: 30)
                }
                
                // Marker circle
                ZStack {
                    Circle()
                        .fill(Color.brown)
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
                    
                    Text("\(number)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Bottom line
                if !isLastItem {
                    VerticalDashedLine()
                        .stroke(Color.brown.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .frame(width: 2, height: 30)
                }
            }
            .frame(width: 50)
            
            // Right content
            if direction == .right {
                contentCard
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var contentCard: some View {
        HStack(spacing: 8) {
            if direction == .right {
                Spacer()
                chevronIndicator
            }
            
            VStack(alignment: direction == .right ? .trailing : .leading, spacing: 4) {
                Text(stop.shopName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(direction == .right ? .trailing : .leading)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("~\(stop.estimatedTimeMinutes) min")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            if direction == .left {
                chevronIndicator
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.brown.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var chevronIndicator: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.brown)
            .imageScale(.small)
    }
}

// MARK: - Vertical Dashed Line
struct VerticalDashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

