import SwiftUI
import MapKit
import CoreLocation
import Combine

/// ViewModel responsible for managing coffee shop data, user interactions, and app state
class CoffeeHunterViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var locationName: String = "your location"
    @Published var isLocationThrottled = false
    @Published var throttleTimeRemaining: Int = 0
    @Published var selectedCoffeeShop: CoffeeShop?
    @Published var showAchievementAlert = false
    @Published var selectedTab: Int = 0
    
    // MARK: - Dependencies
    private let dataManager: CoffeeHunterDataManager
    private let coffeeShopService: CoffeeShopService
    let locationManager = LocationManager()
    
    // MARK: - Private Properties
    private var throttleTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var favorites: [CoffeeShop] { dataManager.favorites }
    var visitHistory: [CoffeeShopVisit] { dataManager.visitHistory }
    var isPremium: Bool { dataManager.isPremium }
    var coffeeShops: [CoffeeShop] { coffeeShopService.coffeeShops }
    
    var hasVisitHistory: Bool { !dataManager.visitHistory.isEmpty }
    var sortedCoffeeShopsByDistance: [CoffeeShop] {
        coffeeShopService.coffeeShops.sorted { $0.distance < $1.distance }
    }

    init(dataManager: CoffeeHunterDataManager = CoffeeHunterDataManager(),
         coffeeShopService: CoffeeShopService = CoffeeShopService()) {
        self.dataManager = dataManager
        self.coffeeShopService = coffeeShopService
    }
    
    // MARK: - Coffee Shop Management
    func toggleFavorite(_ shop: CoffeeShop) {
        if isFavorite(shop) {
            dataManager.removeFavorite(shop)
        } else {
            dataManager.addFavorite(shop)
        }
        
        if selectedCoffeeShop?.id == shop.id {
            selectedCoffeeShop = shop
        }
    }
    
    func isFavorite(_ shop: CoffeeShop) -> Bool {
        dataManager.favorites.contains(where: { $0.id == shop.id })
    }
    
    func getRandomCoffeeShop(userLocation: CLLocation) -> CoffeeShop? {
        return dataManager.getRandomCoffeeShop(from: coffeeShopService.coffeeShops, userLocation: userLocation)
    }
    
    func getShopIndex(_ shop: CoffeeShop) -> Int {
        sortedCoffeeShopsByDistance.firstIndex(of: shop) ?? 0
    }
        
    
    // MARK: - Location Management
    
    func startLocationUpdates() {
        locationManager.$userLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                print("Debug: Got initial user location")
                // Only update if no custom location is set
                if self?.selectedLocation == nil {
                    self?.updateLocation(location)
                }
            }
            .store(in: &cancellables)
        
        locationManager.startContinuousUpdates()
    }
    
    func refreshLocation() {
        if let customLocation = selectedLocation {
            updateLocation(customLocation)
        }
        else if let currentLocation = locationManager.userLocation {
            updateLocation(currentLocation)
        } else {
            locationManager.requestSingleLocationUpdate()
        }
    }
    
    func updateLocation(_ location: CLLocationCoordinate2D) {
        selectedLocation = location
        coffeeShopService.fetchNearbyCoffeeShops(near: location)
        updateLocationName(for: location)
    }
    
    func clearCustomLocation() {
        selectedLocation = nil
        if let currentLocation = locationManager.userLocation {
            updateLocation(currentLocation)
        } else {
            locationManager.requestSingleLocationUpdate()
        }
    }
    
    func navigateToMapWithShop(_ shop: CoffeeShop) {
        selectedTab = 1
        
        updateLocation(shop.coordinates)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selectedCoffeeShop = shop
        }
    }
    
    // MARK: - Visit Management
    
    func addVisit(_ shop: CoffeeShop) {
        dataManager.addVisit(shop)
    }
    
    func clearVisitHistory() {
        dataManager.clearVisitHistory()
    }
    
    func hasVisitedToday(_ shop: CoffeeShop) -> Bool {
        let calendar = Calendar.current
        return dataManager.visitHistory.contains { visit in
            visit.shopName == shop.name &&
            calendar.isDateInToday(visit.date)
        }
    }
    
    func getVisitCount(for shop: CoffeeShop) -> Int {
        dataManager.visitHistory.filter { $0.shopName == shop.name }.count
    }
    
    func getUniqueVisitedPlaces() -> Int {
        Set(dataManager.visitHistory.map { $0.shopName }).count
    }
    
    func hasRegularCustomerStatus() -> Bool {
        let shopVisits = Dictionary(grouping: dataManager.visitHistory, by: { $0.shopName })
        return shopVisits.values.contains(where: { $0.count >= 3 })
    }
    
    // MARK: - Achievement Management
    
    func getAchievements() -> [Achievement] {
        [
            Achievement(
                title: "Coffee Explorer",
                description: "Visit 5 different coffee shops",
                icon: "map.fill",
                isUnlocked: dataManager.visitHistory.count >= 5
            ),
            Achievement(
                title: "Coffee Enthusiast",
                description: "Add 10 coffee shops to favorites",
                icon: "heart.fill",
                isUnlocked: dataManager.favorites.count >= 10
            ),
            Achievement(
                title: "Regular Customer",
                description: "Visit the same coffee shop 3 times",
                icon: "star.fill",
                isUnlocked: hasRegularCustomerStatus()
            )
        ]
    }
    
    // MARK: - Premium Management
    
    func upgradeToPremium() {
        dataManager.setPremiumStatus(true)
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(false)
        }
    }
    
    // MARK: - Private Helpers
    
    private func updateLocationName(for location: CLLocationCoordinate2D) {
        if isLocationThrottled {
            return
        }
        
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(clLocation) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    print("Geocoding error: \(error.localizedDescription)")
                    
                    if error.domain == "GEOErrorDomain" && error.code == -3 {
                        if let timeUntilReset = error.userInfo["timeUntilReset"] as? Int {
                            self.handleThrottling(duration: timeUntilReset)
                        } else {
                            self.handleThrottling(duration: 15)
                        }
                    }
                    
                    self.locationName = "your location"
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    self.locationName = "your location"
                    return
                }
                
                self.locationName = self.formatLocationName(from: placemark)
            }
        }
    }
    
    private func handleThrottling(duration: Int) {
        isLocationThrottled = true
        throttleTimeRemaining = duration
        
        throttleTimer?.invalidate()
        
        throttleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.throttleTimeRemaining -= 1
            
            if self.throttleTimeRemaining <= 0 {
                self.isLocationThrottled = false
                timer.invalidate()
                self.throttleTimer = nil
            }
        }
    }
    
    private func formatLocationName(from placemark: CLPlacemark) -> String {
        if let neighborhood = placemark.subLocality,
           let city = placemark.locality {
            return "\(neighborhood), \(city)"
        }
        
        if let city = placemark.locality {
            return city
        }
        
        if let area = placemark.administrativeArea {
            return area
        }
        
        return "your location"
    }
}
