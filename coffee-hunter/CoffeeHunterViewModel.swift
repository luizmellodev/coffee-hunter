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
    @Published var userStreak: UserStreak = .empty
    @Published var dailyCoffeeShop: CoffeeShop?
    @Published var newAchievements: [Achievement] = []
    @Published var selectedTour: CoffeeTour?
    @Published var selectedGuide: ContentGuide?
    
    // MARK: - Dependencies
    private let dataManager: CoffeeHunterDataManaging
    private let coffeeShopService: CoffeeShopServicing
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
        dataManager: CoffeeHunterDataManaging = CoffeeHunterDataManager(),
        coffeeShopService: CoffeeShopServicing = CoffeeShopService()
    ) {
        self.dataManager = dataManager
        self.coffeeShopService = coffeeShopService
        
        favorites = dataManager.favorites
        visitHistory = dataManager.visitHistory
        isPremium = dataManager.isPremium
        userStreak = dataManager.userStreak
        
        // Load daily recommendation
        updateDailyRecommendation()
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
        
        // Update streak
        dataManager.updateStreak(visitDate: Date())
        userStreak = dataManager.userStreak
        
        // Check for achievements
        checkAndUnlockAchievements()
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
        let uniquePlaces = getUniqueVisitedPlaces()
        let visitedCities = getVisitedCitiesCount()
        
        return [
            // Exploration
            Achievement(
                id: "first_coffee",
                title: "First Specialty Coffee",
                description: "Visit your first coffee shop",
                icon: "cup.and.saucer.fill",
                isUnlocked: visitHistory.count >= 1,
                category: .exploration,
                progress: min(visitHistory.count, 1),
                maxProgress: 1,
                unlockedDate: dataManager.getUnlockedDate(for: "first_coffee"),
                rarity: .common
            ),
            Achievement(
                id: "coffee_explorer",
                title: "Coffee Explorer",
                description: "Visit 5 different coffee shops",
                icon: "map.fill",
                isUnlocked: uniquePlaces >= 5,
                category: .exploration,
                progress: uniquePlaces,
                maxProgress: 5,
                unlockedDate: dataManager.getUnlockedDate(for: "coffee_explorer"),
                rarity: .common
            ),
            Achievement(
                id: "coffee_adventurer",
                title: "Coffee Adventurer",
                description: "Visit 10 different coffee shops",
                icon: "location.fill",
                isUnlocked: uniquePlaces >= 10,
                category: .exploration,
                progress: uniquePlaces,
                maxProgress: 10,
                unlockedDate: dataManager.getUnlockedDate(for: "coffee_adventurer"),
                rarity: .rare
            ),
            Achievement(
                id: "coffee_master",
                title: "Coffee Master",
                description: "Visit 25 different coffee shops",
                icon: "star.circle.fill",
                isUnlocked: uniquePlaces >= 25,
                category: .exploration,
                progress: uniquePlaces,
                maxProgress: 25,
                unlockedDate: dataManager.getUnlockedDate(for: "coffee_master"),
                rarity: .epic
            ),
            
            // Collection
            Achievement(
                id: "coffee_collector",
                title: "Coffee Collector",
                description: "Add 5 coffee shops to favorites",
                icon: "heart.fill",
                isUnlocked: favorites.count >= 5,
                category: .collection,
                progress: favorites.count,
                maxProgress: 5,
                unlockedDate: dataManager.getUnlockedDate(for: "coffee_collector"),
                rarity: .common
            ),
            Achievement(
                id: "coffee_enthusiast",
                title: "Coffee Enthusiast",
                description: "Add 10 coffee shops to favorites",
                icon: "heart.circle.fill",
                isUnlocked: favorites.count >= 10,
                category: .collection,
                progress: favorites.count,
                maxProgress: 10,
                unlockedDate: dataManager.getUnlockedDate(for: "coffee_enthusiast"),
                rarity: .rare
            ),
            
            // Dedication
            Achievement(
                id: "regular_customer",
                title: "Regular Customer",
                description: "Visit the same coffee shop 3 times",
                icon: "repeat.circle.fill",
                isUnlocked: hasRegularCustomerStatus(),
                category: .dedication,
                progress: nil,
                maxProgress: nil,
                unlockedDate: dataManager.getUnlockedDate(for: "regular_customer"),
                rarity: .common
            ),
            Achievement(
                id: "streak_3",
                title: "3-Day Streak",
                description: "Visit coffee shops 3 days in a row",
                icon: "flame.fill",
                isUnlocked: userStreak.currentStreak >= 3,
                category: .dedication,
                progress: userStreak.currentStreak,
                maxProgress: 3,
                unlockedDate: dataManager.getUnlockedDate(for: "streak_3"),
                rarity: .rare
            ),
            Achievement(
                id: "streak_7",
                title: "Coffee Week",
                description: "Visit coffee shops 7 days in a row",
                icon: "flame.fill",
                isUnlocked: userStreak.currentStreak >= 7,
                category: .dedication,
                progress: userStreak.currentStreak,
                maxProgress: 7,
                unlockedDate: dataManager.getUnlockedDate(for: "streak_7"),
                rarity: .epic
            ),
            Achievement(
                id: "streak_30",
                title: "Coffee Master",
                description: "Visit coffee shops 30 days in a row",
                icon: "flame.fill",
                isUnlocked: userStreak.currentStreak >= 30,
                category: .dedication,
                progress: userStreak.currentStreak,
                maxProgress: 30,
                unlockedDate: dataManager.getUnlockedDate(for: "streak_30"),
                rarity: .legendary
            ),
            
            // Social/Cities
            Achievement(
                id: "city_hopper",
                title: "City Hopper",
                description: "Visit coffee shops in 3 different cities",
                icon: "building.2.fill",
                isUnlocked: visitedCities >= 3,
                category: .special,
                progress: visitedCities,
                maxProgress: 3,
                unlockedDate: dataManager.getUnlockedDate(for: "city_hopper"),
                rarity: .epic
            ),
            Achievement(
                id: "globe_trotter",
                title: "Globe Trotter",
                description: "Visit coffee shops in 5 different cities",
                icon: "globe.americas.fill",
                isUnlocked: visitedCities >= 5,
                category: .special,
                progress: visitedCities,
                maxProgress: 5,
                unlockedDate: dataManager.getUnlockedDate(for: "globe_trotter"),
                rarity: .legendary
            )
        ]
    }
    
    private func checkAndUnlockAchievements() {
        let achievements = getAchievements()
        newAchievements.removeAll()
        
        for achievement in achievements where achievement.isUnlocked {
            if !dataManager.isAchievementUnlocked(achievement.id) {
                dataManager.unlockAchievement(achievement.id)
                newAchievements.append(achievement)
            }
        }
        
        if !newAchievements.isEmpty {
            showAchievementAlert = true
        }
    }
    
    private func getVisitedCitiesCount() -> Int {
        // This is a simplified version - in production you'd geocode the shop addresses
        // For now, we'll estimate based on distance between shops
        return min(visitHistory.count / 10, 5)
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
        selectedTab = 1 // Map tab
        selectedCoffeeShop = shop
    }
    
    func getRandomCoffeeShop(userLocation: CLLocation) -> CoffeeShop? {
        dataManager.getRandomCoffeeShop(from: coffeeShopService.coffeeShops, userLocation: userLocation)
    }
    
    func getShopIndex(_ shop: CoffeeShop) -> Int {
        sortedCoffeeShopsByDistance.firstIndex(of: shop) ?? 0
    }
    
    // MARK: - Daily Recommendation
    func updateDailyRecommendation() {
        dailyCoffeeShop = dataManager.getDailyRecommendation(from: coffeeShops)
    }
    
    // MARK: - Tours
    func getAvailableTours(forCity city: String? = nil) -> [CoffeeTour] {
        if let city = city {
            return CoffeeTour.sampleTours.filter { $0.city == city }
        }
        return CoffeeTour.sampleTours
    }
    
    func purchaseTour(_ tour: CoffeeTour, completion: @escaping (Bool) -> Void) {
        // In production, this would integrate with StoreKit
        // For now, simulate purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.dataManager.purchaseTour(tour.id)
            completion(true)
        }
    }
    
    func hasPurchasedTour(_ tour: CoffeeTour) -> Bool {
        return dataManager.hasPurchasedTour(tour.id)
    }
    
    // MARK: - Guides
    func getAvailableGuides(category: ContentGuide.GuideCategory? = nil) -> [ContentGuide] {
        let guides = ContentGuide.sampleGuides
        if let category = category {
            return guides.filter { $0.category == category }
        }
        return guides
    }
    
    func getFreeGuides() -> [ContentGuide] {
        return ContentGuide.freeGuides
    }
    
    func getPremiumGuides() -> [ContentGuide] {
        return ContentGuide.premiumGuides
    }
    
    func purchaseGuide(_ guide: ContentGuide, completion: @escaping (Bool) -> Void) {
        // In production, this would integrate with StoreKit
        // For now, simulate purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.dataManager.purchaseGuide(guide.id)
            completion(true)
        }
    }
    
    func hasPurchasedGuide(_ guide: ContentGuide) -> Bool {
        return dataManager.hasPurchasedGuide(guide.id)
    }
    
    func canAccessGuide(_ guide: ContentGuide) -> Bool {
        return !guide.isPremium || hasPurchasedGuide(guide)
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
