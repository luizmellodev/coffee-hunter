@preconcurrency
import SwiftUI
@preconcurrency import MapKit

struct CoffeeRouteView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @Environment(\.dismiss) var dismiss
    @State private var routeStops: [CoffeeShop]?
    @State private var showingPremiumAlert = false
    @State private var restoringPurchase = false
    @State private var position: MapCameraPosition = .automatic
    @State private var routes: [RouteDetails] = []
    @State private var showMap = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !viewModel.dataManager.isPremium {
                    premiumView
                } else if let stops = routeStops {
                    routeContent(stops)
                } else {
                    emptyState
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
        }
    }
    
    private var premiumView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Recurso Premium")
                .font(.title)
                .bold()
            
            Text("Desbloqueie a Rota do Café para descobrir novos cafés!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button {
                viewModel.upgradeToPremium()
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Tornar-se Premium")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            Button {
                restoringPurchase = true
                viewModel.restorePurchases { success in
                    restoringPurchase = false
                    if !success {
                        showingPremiumAlert = true
                    }
                }
            } label: {
                if restoringPurchase {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Restaurar Compra")
                        .foregroundColor(.secondary)
                }
            }
            .disabled(restoringPurchase)
        }
        .padding()
        .alert("Restaurar Compra", isPresented: $showingPremiumAlert) {
            Button("OK") { }
        } message: {
            Text("Não foi possível encontrar uma compra anterior para restaurar.")
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundColor(.brown)
            
            Text("Crie sua rota do café")
                .font(.title2)
                .bold()
            
            Text("Nós vamos te sugerir uma rota com as melhores cafeterias próximas a você!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button {
                generateRoute()
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Gerar Rota")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.brown)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    @ViewBuilder
    private func routeContent(_ stops: [CoffeeShop]) -> some View {
        VStack(spacing: 0) {
            HStack {
                Picker("", selection: $showMap) {
                    Text("Lista").tag(false)
                    Text("Mapa").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
            .padding(.vertical)
            
            if showMap {
                mapView(stops)
            } else {
                routeList(stops)
            }
        }
    }
    
    private func mapView(_ stops: [CoffeeShop]) -> some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                ForEach(stops) { shop in
                    Marker(shop.name, coordinate: shop.coordinates)
                        .tint(.brown)
                }
                
//                ForEach(routes, id: \.id) { routeDetails in
//                    MapPolyline(coordinates: routeDetails.coordinates)
//                        .stroke(.brown, lineWidth: 3)
//                }
            }
            .onAppear {
                calculateRoute(for: stops)
            }
            
            routeInfo(stops)
                .padding()
        }
    }
    
    private func routeInfo(_ stops: [CoffeeShop]) -> some View {
        VStack {
            ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                HStack {
                    Circle()
                        .fill(Color.brown)
                        .frame(width: 8, height: 8)
                    
                    Text(stop.name)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if index < stops.count - 1 {
                        if let route = routes[safe: index] {
                            Text(formatTime(route.duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private func routeList(_ stops: [CoffeeShop]) -> some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(stops) { shop in
                        ModernCoffeeCard(shop: shop, viewModel: viewModel)
                            .frame(height: 220)
                    }
                }
                .padding()
            }
            
            Button {
                generateRoute()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Gerar Nova Rota")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.brown.opacity(0.1))
                .foregroundColor(.brown)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func generateRoute() {
        guard viewModel.dataManager.isPremium else {
            return
        }
        
        routeStops = viewModel.dataManager.generateCoffeeRoute(
            from: viewModel.coffeeShopService.coffeeShops
        )
        
        if let stops = routeStops {
            calculateRoute(for: stops)
            if let first = stops.first {
                position = .region(MKCoordinateRegion(
                    center: first.coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            }
        }
    }
    
    private func calculateRoute(for stops: [CoffeeShop]) {
        routes.removeAll()
        
        guard stops.count >= 2 else { return }
        
        let group = DispatchGroup()
        var newRoutes: [RouteDetails] = []
        
        for i in 0..<stops.count-1 {
            group.enter()
            
            let source = stops[i]
            let destination = stops[i + 1]
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: source.coordinates))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinates))
            request.transportType = .walking
            
            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                if let route = response?.routes.first {
                    let coordinates = route.polyline.coordinates
                    let routeDetails = RouteDetails(
                        id: UUID(),
                        coordinates: coordinates,
                        duration: route.expectedTravelTime
                    )
                    newRoutes.append(routeDetails)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.routes = newRoutes.sorted { $0.duration < $1.duration }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        return "\(minutes) min"
    }
}

struct RouteDetails: Identifiable, Hashable {
    let id: UUID
    let coordinates: [CLLocationCoordinate2D]
    let duration: TimeInterval
    
    static func == (lhs: RouteDetails, rhs: RouteDetails) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
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

struct MapPolyline: Shape {
    let coordinates: [CLLocationCoordinate2D]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !coordinates.isEmpty else { return path }
        
        path.move(to: point(for: coordinates[0], in: rect))
        
        for coordinate in coordinates.dropFirst() {
            path.addLine(to: point(for: coordinate, in: rect))
        }
        
        return path
    }
    
    private func point(for coordinate: CLLocationCoordinate2D, in rect: CGRect) -> CGPoint {
        let latitude = Double(rect.height) * (coordinate.latitude - coordinates.map { $0.latitude }.min()!) / (coordinates.map { $0.latitude }.max()! - coordinates.map { $0.latitude }.min()!)
        let longitude = Double(rect.width) * (coordinate.longitude - coordinates.map { $0.longitude }.min()!) / (coordinates.map { $0.longitude }.max()! - coordinates.map { $0.longitude }.min()!)
        return CGPoint(x: longitude, y: rect.height - latitude)
    }
}
