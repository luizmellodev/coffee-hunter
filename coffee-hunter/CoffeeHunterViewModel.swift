//
//  CoffeeHunterViewModel.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

class CoffeeHunterViewModel: ObservableObject {
    // MARK: - Published UI State
    @Published var favorites: [CoffeeShop] = []
    @Published var visitHistory: [CoffeeShopVisit] = []
    @Published var isPremium: Bool = false
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var locationName: String = "your location"
    @Published var isLocationThrottled = false
    @Published var throttleTimeRemaining = 0
    @Published var selectedCoffeeShop: CoffeeShop?
    @Published var showAchievementAlert = false
    @Published var selectedTab = 0
    
    // MARK: - Dependencies
    private let dataManager: CoffeeHunterDataManager
    private let coffeeShopService: CoffeeShopService
    let locationManager = LocationManager()
    
    // MARK: - Private
    private var throttleTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed
    var hasVisitHistory: Bool { !visitHistory.isEmpty }
    var coffeeShops: [CoffeeShop] { coffeeShopService.coffeeShops }
    var sortedCoffeeShopsByDistance: [CoffeeShop] {
        coffeeShops.sorted { $0.distance < $1.distance }
    }
    
    // MARK: - Init
    init(
        dataManager: CoffeeHunterDataManager = CoffeeHunterDataManager(),
        coffeeShopService: CoffeeShopService = CoffeeShopService()
    ) {
        self.dataManager = dataManager
        self.coffeeShopService = coffeeShopService
        
        favorites = dataManager.favorites
        visitHistory = dataManager.visitHistory
        isPremium = dataManager.isPremium
    }
    
    // MARK: - Favorites
    func toggleFavorite(_ shop: CoffeeShop) {
        if isFavorite(shop) {
            dataManager.removeFavorite(shop)
        } else {
            dataManager.addFavorite(shop)
        }
        favorites = dataManager.favorites
        if selectedCoffeeShop?.id == shop.id {
            selectedCoffeeShop = shop
        }
    }
    
    func isFavorite(_ shop: CoffeeShop) -> Bool {
        favorites.contains(where: { $0.id == shop.id })
    }
    
    // MARK: - Visits
    func addVisit(_ shop: CoffeeShop) {
        dataManager.addVisit(shop)
        visitHistory = dataManager.visitHistory
    }
    
    func clearVisitHistory() {
        dataManager.clearVisitHistory()
        visitHistory = []
    }
    
    func hasVisitedToday(_ shop: CoffeeShop) -> Bool {
        let calendar = Calendar.current
        return visitHistory.contains {
            $0.shopName == shop.name && calendar.isDateInToday($0.date)
        }
    }
    
    func getVisitCount(for shop: CoffeeShop) -> Int {
        visitHistory.filter { $0.shopName == shop.name }.count
    }
    
    func getUniqueVisitedPlaces() -> Int {
        Set(visitHistory.map { $0.shopName }).count
    }
    
    func hasRegularCustomerStatus() -> Bool {
        let grouped = Dictionary(grouping: visitHistory, by: { $0.shopName })
        return grouped.values.contains { $0.count >= 3 }
    }
    
    // MARK: - Achievements
    func getAchievements() -> [Achievement] {
        [
            Achievement(
                title: "Coffee Explorer",
                description: "Visit 5 different coffee shops",
                icon: "map.fill",
                isUnlocked: visitHistory.count >= 5
            ),
            Achievement(
                title: "Coffee Enthusiast",
                description: "Add 10 coffee shops to favorites",
                icon: "heart.fill",
                isUnlocked: favorites.count >= 10
            ),
            Achievement(
                title: "Regular Customer",
                description: "Visit the same coffee shop 3 times",
                icon: "star.fill",
                isUnlocked: hasRegularCustomerStatus()
            )
        ]
    }
    
    // MARK: - Premium
    func upgradeToPremium() {
        dataManager.setPremiumStatus(true)
        isPremium = true
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(false)
        }
    }
    
    // MARK: - Location
    func startLocationUpdates() {
        locationManager.$userLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self = self else { return }
                if self.selectedLocation == nil {
                    self.updateLocation(location)
                }
            }
            .store(in: &cancellables)
        
        locationManager.startContinuousUpdates()
    }
    
    func refreshLocation() {
        if let customLocation = selectedLocation {
            updateLocation(customLocation)
        } else if let currentLocation = locationManager.userLocation {
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
        if let current = locationManager.userLocation {
            updateLocation(current)
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
    
    func getRandomCoffeeShop(userLocation: CLLocation) -> CoffeeShop? {
        dataManager.getRandomCoffeeShop(from: coffeeShopService.coffeeShops, userLocation: userLocation)
    }
    
    func getShopIndex(_ shop: CoffeeShop) -> Int {
        sortedCoffeeShopsByDistance.firstIndex(of: shop) ?? 0
    }

    
    // MARK: - Private
    private func updateLocationName(for location: CLLocationCoordinate2D) {
        guard !isLocationThrottled else { return }
        
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(clLocation) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if error != nil {
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
            guard let self else {
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
        if let city = placemark.locality { return city }
        if let area = placemark.administrativeArea { return area }
        return "your location"
    }
}
