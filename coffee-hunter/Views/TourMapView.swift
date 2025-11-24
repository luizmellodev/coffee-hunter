//
//  TourMapView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit

struct TourMapView: View {
    let tour: CoffeeTour
    @Environment(\.dismiss) var dismiss
    @State private var selectedStopId: String?
    @State private var cameraPosition: MapCameraPosition
    
    private var selectedStop: TourStop? {
        guard let id = selectedStopId else { return nil }
        return tour.stops.first(where: { $0.id == id })
    }
    
    init(tour: CoffeeTour) {
        self.tour = tour
        
        // Calculate center and span to show all stops
        if !tour.stops.isEmpty {
            let latitudes = tour.stops.map { $0.latitude }
            let longitudes = tour.stops.map { $0.longitude }
            
            let centerLat = latitudes.reduce(0, +) / Double(latitudes.count)
            let centerLon = longitudes.reduce(0, +) / Double(longitudes.count)
            let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
            
            let maxLat = latitudes.max() ?? centerLat
            let minLat = latitudes.min() ?? centerLat
            let maxLon = longitudes.max() ?? centerLon
            let minLon = longitudes.min() ?? centerLon
            
            let latDelta = (maxLat - minLat) * 1.5
            let lonDelta = (maxLon - minLon) * 1.5
            
            let region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(
                    latitudeDelta: max(latDelta, 0.01),
                    longitudeDelta: max(lonDelta, 0.01)
                )
            )
            
            _cameraPosition = State(initialValue: .region(region))
        } else {
            _cameraPosition = State(initialValue: .automatic)
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Map with route
            Map(position: $cameraPosition) {
                // Draw route lines
                ForEach(Array(tour.stops.enumerated().dropLast()), id: \.element.id) { index, stop in
                    let nextStop = tour.stops[index + 1]
                    
                    MapPolyline(coordinates: [stop.coordinates, nextStop.coordinates])
                        .stroke(.brown, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [10, 5]))
                }
                
                // Place markers for each stop
                ForEach(Array(tour.stops.enumerated()), id: \.element.id) { index, stop in
                    Annotation(stop.shopName, coordinate: stop.coordinates) {
                        StopMarker(stop: stop, number: index + 1, isSelected: selectedStopId == stop.id)
                            .onTapGesture {
                                withAnimation {
                                    selectedStopId = stop.id
                                }
                            }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            
            // Bottom info card
            if let selected = selectedStop {
                stopInfoCard(stop: selected)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                tourInfoCard
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle("Tour Route")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Reset to show all stops
                    selectedStopId = nil
                    recenterMap()
                } label: {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.brown)
                }
            }
        }
    }
    
    // MARK: - Tour Info Card
    private var tourInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tour.name)
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        Label("\(tour.stops.count) stops", systemImage: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label(String(format: "%.1f km", tour.estimatedDistance), systemImage: "figure.walk")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label(tour.duration.displayName, systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Text("Tap any marker to see details")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        .padding()
    }
    
    // MARK: - Stop Info Card
    private func stopInfoCard(stop: TourStop) -> some View {
        let stopIndex = tour.stops.firstIndex(where: { $0.id == stop.id }) ?? 0
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Stop number
                ZStack {
                    Circle()
                        .fill(Color.brown)
                        .frame(width: 36, height: 36)
                    
                    Text("\(stopIndex + 1)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(stop.shopName)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Label("~\(stop.estimatedTimeMinutes) min", systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let recommended = stop.recommendedItem {
                            Label(recommended, systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Close button
                Button {
                    withAnimation {
                        selectedStopId = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(stop.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Action buttons
            HStack(spacing: 12) {
                // View full details
                NavigationLink(destination: TourStopDetailView(stop: stop, stopNumber: stopIndex + 1)) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("View Details")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.brown)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // Open in Maps
                Button {
                    openInMaps(stop: stop)
                } label: {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Navigate")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.brown)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.brown.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        .padding()
    }
    
    // MARK: - Helpers
    private func recenterMap() {
        if !tour.stops.isEmpty {
            let latitudes = tour.stops.map { $0.latitude }
            let longitudes = tour.stops.map { $0.longitude }
            
            let centerLat = latitudes.reduce(0, +) / Double(latitudes.count)
            let centerLon = longitudes.reduce(0, +) / Double(longitudes.count)
            let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
            
            let maxLat = latitudes.max() ?? centerLat
            let minLat = latitudes.min() ?? centerLat
            let maxLon = longitudes.max() ?? centerLon
            let minLon = longitudes.min() ?? centerLon
            
            let latDelta = (maxLat - minLat) * 1.5
            let lonDelta = (maxLon - minLon) * 1.5
            
            let region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(
                    latitudeDelta: max(latDelta, 0.01),
                    longitudeDelta: max(lonDelta, 0.01)
                )
            )
            
            withAnimation {
                cameraPosition = .region(region)
            }
        }
    }
    
    private func openInMaps(stop: TourStop) {
        let placemark = MKPlacemark(coordinate: stop.coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = stop.shopName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}

// MARK: - Stop Marker Component
struct StopMarker: View {
    let stop: TourStop
    let number: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer ring for selected state
                if isSelected {
                    Circle()
                        .stroke(Color.brown, lineWidth: 3)
                        .frame(width: 54, height: 54)
                        .animation(.spring(response: 0.3), value: isSelected)
                }
                
                // Main marker
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isSelected ? [.brown, .brown.opacity(0.8)] : [.brown.opacity(0.9), .brown.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                
                // Number
                Text("\(number)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Coffee icon below
            Image(systemName: "cup.and.saucer.fill")
                .font(.caption2)
                .foregroundColor(.brown)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

