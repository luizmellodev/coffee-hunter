//
//  TourStopDetailView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit

struct TourStopDetailView: View {
    let stop: TourStop
    let stopNumber: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image Placeholder
                heroSection
                
                // Main Content
                VStack(alignment: .leading, spacing: 24) {
                    // Title & Quick Info
                    titleSection
                    
                    Divider()
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    Divider()
                    
                    // About
                    aboutSection
                    
                    Divider()
                    
                    // What to Order
                    if let recommendedItem = stop.recommendedItem {
                        whatToOrderSection(item: recommendedItem)
                        Divider()
                    }
                    
                    // Personal Experience
                    experienceSection
                    
                    Divider()
                    
                    // The Space
                    spaceSection
                    
                    Divider()
                    
                    // Location Map
                    locationSection
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Stop \(stopNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(stop.shopName)
                        .font(.headline)
                }
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder gradient
            LinearGradient(
                colors: [.brown.opacity(0.4), .brown.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            
            // Stop number badge
            HStack {
                Text("Stop \(stopNumber)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.brown)
                    .clipShape(Capsule())
                    .padding()
                
                Spacer()
            }
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(stop.shopName)
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                Label("\(stop.estimatedTimeMinutes) min", systemImage: "clock.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label("Specialty Coffee", systemImage: "cup.and.saucer.fill")
                    .font(.subheadline)
                    .foregroundColor(.brown)
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Open in Maps App
            Button {
                openInMaps()
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Open in Apple Maps")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Get directions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Search on Google
            Button {
                searchOnGoogle()
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Search on Google")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Find more info")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("About this place")
            
            Text(stop.description)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
    }
    
    // MARK: - What to Order
    private func whatToOrderSection(item: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("What to order")
            
            HStack(spacing: 12) {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recommended")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(item)
                        .font(.headline)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Experience Section
    private var experienceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("My experience")
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
            }
            
            Text("This is one of my favorite spots in the city. The baristas really know their craft and the atmosphere is perfect for both working and relaxing. I've visited countless times and it never disappoints.")
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            // Rating-style elements
            HStack(spacing: 16) {
                featureBadge(icon: "cup.and.saucer.fill", label: "Great Coffee")
                featureBadge(icon: "wifi", label: "Good WiFi")
                featureBadge(icon: "bolt.fill", label: "Fast Service")
            }
        }
    }
    
    private func featureBadge(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(label)
                .font(.caption)
        }
        .foregroundColor(.brown)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.brown.opacity(0.1))
        .clipShape(Capsule())
    }
    
    // MARK: - Space Section
    private var spaceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("The space")
            
            Text("Cozy and modern interior with plenty of natural light. Features comfortable seating areas perfect for remote work, with accessible power outlets throughout. The space gets busy during peak hours (9-11 AM and 2-4 PM) but there's usually a spot available.")
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            // Space features
            VStack(spacing: 12) {
                spaceFeature(icon: "laptopcomputer", title: "Work-friendly", description: "Power outlets available")
                spaceFeature(icon: "person.2.fill", title: "Seating", description: "30-40 seats")
                spaceFeature(icon: "sun.max.fill", title: "Ambiance", description: "Bright & airy")
            }
        }
    }
    
    private func spaceFeature(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brown)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Location")
            
            // Mini Map
            Map(initialPosition: .region(MKCoordinateRegion(
                center: stop.coordinates,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))) {
                Marker(stop.shopName, coordinate: stop.coordinates)
                    .tint(.brown)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .allowsHitTesting(false)
            
            // Map action buttons
            HStack(spacing: 8) {
                // Apple Maps button
                Button {
                    openInMaps()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        Text("Apple Maps")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.brown)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Google Maps button
                Button {
                    openInGoogleMaps()
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Details")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.brown)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.brown.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: stop.coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = stop.shopName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    private func openInGoogleMaps() {
        // Encode the search query (name for better results)
        let searchQuery = stop.shopName
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Try to open in Google Maps app first
        if let googleMapsURL = URL(string: "comgooglemaps://?q=\(encodedQuery)&center=\(stop.coordinates.latitude),\(stop.coordinates.longitude)"),
           UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL)
        } 
        // Fallback to Google Maps web version (always works)
        else if let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encodedQuery)") {
            UIApplication.shared.open(webURL)
        }
    }
    
    private func searchOnGoogle() {
        let query = stop.shopName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://www.google.com/search?q=\(query)") {
            UIApplication.shared.open(url)
        }
    }
}

