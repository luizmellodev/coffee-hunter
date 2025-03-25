import SwiftUI
import MapKit
import CoreLocation

struct RandomCoffeePickerView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedShop: CoffeeShop?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isLoading {
                    ProgressView("Procurando o café perfeito...")
                        .padding(.top, 40)
                } else if let shop = selectedShop {
                    VStack(spacing: 24) {
                        Text(" Encontramos seu café! ")
                            .font(.title2)
                            .bold()
                        
                        ModernCoffeeCard(shop: shop, viewModel: viewModel)
                            .padding(.horizontal)
                        
                        // Botões
                        VStack(spacing: 12) {
                            Button {
                                print("Debug: Navigating to map with shop: \(shop.name)")
                                viewModel.navigateToMapWithShop(shop)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "map")
                                    Text("Ver no Mapa")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button {
                                print("Debug: Opening in Maps: \(shop.name)")
                                let coordinate = shop.coordinates
                                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                                mapItem.name = shop.name
                                mapItem.openInMaps(launchOptions: [
                                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                                ])
                            } label: {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Ir para o café")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: pickRandomShop) {
                                Text("Tentar outro")
                                    .foregroundColor(.brown)
                            }
                            .padding(.top)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                } else {
                    Text("Nenhum café encontrado em um raio de 10km")
                        .padding(.top, 40)
                }
            }
            .navigationTitle("Escolha pra mim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
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
    
    private func pickRandomShop() {
        isLoading = true
        print("Debug: Starting pickRandomShop")
        
        guard let coordinate = viewModel.locationManager.userLocation else {
            print("Debug: No user location available")
            isLoading = false
            return
        }
        
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        print("Debug: Available coffee shops: \(viewModel.coffeeShopService.coffeeShops.count)")
        
        // Add delay for UI feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let shop = viewModel.dataManager.getRandomCoffeeShop(
                from: viewModel.coffeeShopService.coffeeShops,
                userLocation: userLocation
            ) {
                print("Debug: Found random shop: \(shop.name)")
                self.selectedShop = shop
            } else {
                print("Debug: No shop found")
            }
            isLoading = false
        }
    }
}
