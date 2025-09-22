import SwiftUI
import MapKit
import CoreLocation

struct RandomCoffeePickerView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedShop: CoffeeShop?
    @State private var isLoading = false
    @State private var showContent = false
    @State private var rotationAngle = 0.0
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    loadingView
                } else if let shop = selectedShop {
                    successView(shop: shop)
                } else {
                    emptyView
                }
            }
            .navigationTitle("Coffee Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                print("Debug: RandomCoffeePickerView appeared")
                if viewModel.coffeeShopService.coffeeShops.isEmpty {
                    print("Debug: No coffee shops loaded, fetching...")
                    if let location = viewModel.locationManager.userLocation {
                        viewModel.updateLocation(location)
                    }
                }
                pickRandomShop()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 60))
                .foregroundColor(.brown)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
            
            Text("Finding the perfect coffee...")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Brewing something special for you")
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    private func successView(shop: CoffeeShop) -> some View {
        VStack(spacing: 32) {
            successHeaderView
            
            ModernCoffeeCard(shop: shop, viewModel: viewModel)
                .padding(.horizontal)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 50)
            
            actionButtonsView(for: shop)
        }
        .padding(.vertical)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    
    private var successHeaderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.5)
            
            Text("We found your coffee!")
                .font(.title)
                .fontWeight(.bold)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            
            Text("This place matches your coffee preferences")
                .foregroundColor(.secondary)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
        }
    }
    
    private func actionButtonsView(for shop: CoffeeShop) -> some View {
        VStack(spacing: 16) {
            viewInMapButton(for: shop)
            getDirectionsButton(for: shop)
            tryAnotherButton
        }
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 30)
    }
    
    private func viewInMapButton(for shop: CoffeeShop) -> some View {
        Button {
            print("Debug: Navigating to map with shop: \(shop.name)")
            viewModel.navigateToMapWithShop(shop)
            dismiss()
        } label: {
            Label("View this coffee shop", systemImage: "map")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private func getDirectionsButton(for shop: CoffeeShop) -> some View {
        Button {
            print("Debug: Opening in Maps: \(shop.name)")
            let coordinate = shop.coordinates
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            mapItem.name = shop.name
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        } label: {
            Label("Get directions", systemImage: "location.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brown.opacity(0.15))
                .foregroundColor(.brown)
                .cornerRadius(10)
        }
    }
    
    private var tryAnotherButton: some View {
        Button(action: pickRandomShop) {
            Text("Try another one")
                .foregroundColor(.brown)
                .padding(.vertical, 8)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No coffee shops found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Try expanding your search area")
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
    
    private func pickRandomShop() {
        showContent = false
        isLoading = true
        rotationAngle = 0
        print("Debug: Starting pickRandomShop")
        
        guard let coordinate = viewModel.locationManager.userLocation else {
            print("Debug: No user location available")
            isLoading = false
            return
        }
        
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        print("Debug: Available coffee shops: \(viewModel.coffeeShopService.coffeeShops.count)")
        
        // Add delay for UI feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let shop = viewModel.dataManager.getRandomCoffeeShop(
                from: viewModel.coffeeShopService.coffeeShops,
                userLocation: userLocation
            ) {
                print("Debug: Found random shop: \(shop.name)")
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.selectedShop = shop
                    self.isLoading = false
                }
            } else {
                print("Debug: No shop found")
                withAnimation {
                    self.isLoading = false
                }
            }
        }
    }
}
