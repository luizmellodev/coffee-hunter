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
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $position, selection: $viewModel.selection) {
            ForEach(viewModel.coffeeShopService.coffeeShops, id: \.self) { shop in
                Marker(item: shop)
                    .tint(viewModel.selection == shop ? .brown : .gray)
            }
            .mapItemDetailSelectionAccessory()
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
//        .safeAreaInset(edge: .bottom) {
//            if let selection = viewModel.selection {
//                HStack {
//                    Button {
//                        viewModel.toggleFavorite(selection)
//                    } label: {
//                        Label(
//                            viewModel.isFavorite(selection) ? "Remove from Favorites" : "Add to Favorites",
//                            systemImage: viewModel.isFavorite(selection) ? "heart.fill" : "heart"
//                        )
//                        .labelStyle(.iconOnly)
//                        .foregroundStyle(viewModel.isFavorite(selection) ? .red : .primary)
//                    }
//                    .padding(12)
//                    .background(.ultraThinMaterial)
//                    .clipShape(Circle())
//
//                    Button {
//                        viewModel.dataManager.addVisit(selection)
//                    } label: {
//                        Label("Check In", systemImage: "checkmark.circle")
//                            .labelStyle(.iconOnly)
//                    }
//                    .padding(12)
//                    .background(.ultraThinMaterial)
//                    .clipShape(Circle())
//                }
//                .padding(.bottom)
//            }
//        }
//        .onChange(of: viewModel.selection) { _, shop in
//            guard let shop = shop else { return }
//            withAnimation {
//                position = .region(MKCoordinateRegion(
//                    center: shop.placemark.coordinate,
//                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//                ))
//            }
//        }
    }
}

#Preview {
    let viewModel = CoffeeHunterViewModel()
    
    CoffeeMapView(viewModel: viewModel)
}
