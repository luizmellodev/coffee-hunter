//
//  ShopBottomCard.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ShopBottomCard: View {
    let shop: CoffeeShop
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            HStack(spacing: 15) {
                ZStack {
                    Color.brown.opacity(0.15)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.brown)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(shop.name)
                        .font(.title3)
                        .bold()
                    
                    Text(shop.address)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack {
                        Label(String(format: "%.1f", shop.rating), systemImage: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Spacer()
                        
                        Button(action: openInMaps) {
                            Text("Open in Maps")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.brown)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding()
    }
    
    private func openInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: shop.coordinates))
        mapItem.name = shop.name
        mapItem.openInMaps()
    }
}

// Add searchLocation helper function
func searchLocation(_ query: String, viewModel: CoffeeHunterViewModel) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(query) { placemarks, _ in
        if let location = placemarks?.first?.location?.coordinate {
            // Calculate distance from user location
            if let userLocation = viewModel.locationManager.userLocation {
                let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let searchCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                
                let distanceInKm = userCLLocation.distance(from: searchCLLocation) / 1000
                
                // Only update if within 150km
                if distanceInKm <= 150 {
                    viewModel.updateLocation(location)
                }
            }
        }
    }
}
