//
//  CoffeeMapView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import MapKit
import CoreLocation
import SwiftUI

struct CoffeeMapView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var position: MapCameraPosition

    init(viewModel: CoffeeHunterViewModel) {
        self.viewModel = viewModel
        
        if let selectedLocation = viewModel.selectedLocation {
            self._position = State(initialValue: .region(MKCoordinateRegion(
                center: selectedLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        } else {
            self._position = State(initialValue: .userLocation(fallback: .automatic))
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // MARK: - Map
            Map(position: $position, selection: $viewModel.selectedCoffeeShop) {
                ForEach(viewModel.coffeeShops) { shop in
                    Marker(shop.name, coordinate: shop.coordinates)
                        .tint(viewModel.selectedCoffeeShop?.id == shop.id ? .brown : .gray)
                        .tag(shop)
                }
                UserAnnotation()
            }
            .mapStyle(.standard)
            
            // MARK: - Buttons
            VStack(spacing: 12) {
                if let selectedLocation = viewModel.selectedLocation {
                    Button {
                        withAnimation {
                            position = .region(MKCoordinateRegion(
                                center: selectedLocation,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            ))
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 22))
                            Text("Search Area")
                                .font(.caption2)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                    }
                } else {
                    MapUserLocationButton()
                        .buttonBorderShape(.circle)
                        .tint(.blue)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .onReceive(viewModel.$selectedLocation) { location in
            guard let location = location else { return }
            moveCamera(to: location, zoom: 0.05)
        }
        .onChange(of: viewModel.selectedCoffeeShop) { _, shop in
            guard let shop = shop else { return }
            moveCamera(to: shop.coordinates, zoom: 0.01)
        }
    }

    private func moveCamera(to location: CLLocationCoordinate2D, zoom: Double) {
        withAnimation {
            position = .region(MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
            ))
        }
    }
}

#Preview {
    let viewModel = CoffeeHunterViewModel()
    CoffeeMapView(viewModel: viewModel)
}
