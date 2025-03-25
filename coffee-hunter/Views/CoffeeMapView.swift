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
    @Binding var selectedIndex: Int
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $position, selection: $viewModel.selectedCoffeeShop) {
            ForEach(viewModel.coffeeShopService.coffeeShops) { shop in
                Marker(shop.name, coordinate: shop.coordinates)
                    .tint(viewModel.selectedCoffeeShop == shop ? .brown : .gray)
                    .tag(shop)
            }
            .mapItemDetailSelectionAccessory()
            UserAnnotation()
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
                .buttonBorderShape(.circle)
                .tint(.white)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .onChange(of: selectedIndex) { _, newIndex in
            let sortedShops = viewModel.coffeeShopService.coffeeShops.sorted { $0.distance < $1.distance }
            guard newIndex < sortedShops.count else { return }
            
            let shop = sortedShops[newIndex]
            viewModel.selectedCoffeeShop = shop
            updateRegion(for: shop)
        }
        .onChange(of: viewModel.selectedCoffeeShop) { _, shop in
            guard let shop = shop else { return }
            if let index = viewModel.coffeeShopService.coffeeShops
                .sorted(by: { $0.distance < $1.distance })
                .firstIndex(of: shop) {
                selectedIndex = index
                updateRegion(for: shop)
            }
        }
    }
    
    private func updateRegion(for shop: CoffeeShop) {
        withAnimation {
            position = .region(MKCoordinateRegion(
                center: shop.coordinates,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
}

#Preview {
    let viewModel = CoffeeHunterViewModel()
    
    CoffeeMapView(viewModel: viewModel, selectedIndex: .constant(0))
}
