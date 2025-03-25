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
            VStack {
                if isLoading {
                    ProgressView("Procurando o café perfeito...")
                } else if let shop = selectedShop {
                    VStack(spacing: 20) {
                        Text(" Encontramos seu café! ")
                            .font(.title2)
                            .bold()
                        
                        ModernCoffeeCard(shop: shop, viewModel: viewModel)
                            .padding()
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                viewModel.selectedCoffeeShop = shop
                                viewModel.updateLocation(shop.coordinates)
                                dismiss()
                            }) {
                                Label("Ver no Mapa", systemImage: "map")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                let coordinate = shop.coordinates
                                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                                mapItem.name = shop.name
                                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                            }) {
                                Label("Ir para este café", systemImage: "location.fill")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        Button("Tentar outro", action: pickRandomShop)
                            .padding()
                    }
                } else {
                    Text("Nenhum café encontrado em um raio de 10km")
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Escolha pra mim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: pickRandomShop)
        }
    }
    
    private func pickRandomShop() {
        isLoading = true
        guard let coordinate = viewModel.locationManager.userLocation else {
            isLoading = false
            return
        }
        
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            selectedShop = viewModel.dataManager.getRandomCoffeeShop(
                from: viewModel.coffeeShopService.coffeeShops,
                userLocation: userLocation
            )
            isLoading = false
        }
    }
}
