import SwiftUI

struct CoffeeRouteView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showPremiumAlert = false
    @State private var routeStops: [CoffeeShop]?
    @State private var showingRestorePurchaseAlert = false
    @State private var restoringPurchase = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.dataManager.isPremium {
                    PremiumPromotionView(
                        onPurchase: { viewModel.upgradeToPremium() },
                        onRestore: {
                            restoringPurchase = true
                            viewModel.restorePurchases { success in
                                restoringPurchase = false
                                if !success {
                                    showingRestorePurchaseAlert = true
                                }
                            }
                        },
                        isRestoring: restoringPurchase
                    )
                } else {
                    if let stops = routeStops {
                        List {
                            Section(header: Text("Sua rota do café")) {
                                ForEach(stops, id: \.id) { shop in
                                    ModernCoffeeCard(shop: shop, viewModel: viewModel)
                                        .padding(.vertical, 8)
                                }
                            }
                            
                            Section {
                                Button("Gerar nova rota") {
                                    generateRoute()
                                }
                            }
                        }
                    } else {
                        Button("Gerar rota do café") {
                            generateRoute()
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    MissionsView(viewModel: viewModel)
                }
            }
            .navigationTitle("Rota do Café")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
            .alert("Restaurar Compra", isPresented: $showingRestorePurchaseAlert) {
                Button("OK") { }
            } message: {
                Text("Não foi possível encontrar uma compra anterior para restaurar.")
            }
        }
    }
    
    private func generateRoute() {
        routeStops = viewModel.dataManager.generateCoffeeRoute(
            from: viewModel.coffeeShopService.coffeeShops
        )
    }
}

struct PremiumPromotionView: View {
    var onPurchase: () -> Void
    var onRestore: () -> Void
    var isRestoring: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Feature Premium")
                .font(.title)
                .bold()
            
            Text("Desbloqueie a Rota do Café e muito mais!")
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button("Tornar-se Premium") {
                    onPurchase()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .foregroundColor(.black)
                .cornerRadius(10)
                
                Button(action: onRestore) {
                    if isRestoring {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    } else {
                        Text("Restaurar Compra")
                    }
                }
                .disabled(isRestoring)
                .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct MissionsView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    
    var body: some View {
        List {
            Section(header: Text("Suas Missões")) {
                ForEach(viewModel.dataManager.missions) { mission in
                    VStack(alignment: .leading) {
                        Text(mission.title)
                            .font(.headline)
                        Text(mission.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(mission.points) pontos")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
