import XCTest
import CoreLocation
import MapKit
@testable import coffee_hunter

final class CoffeeHunterDataManagerTests: XCTestCase {
    var sut = CoffeeHunterDataManager()
    let userDefaults = UserDefaults.standard
    
    private var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "coffee_hunter_tests"
    }
    
    override func setUp() {
        super.setUp()
        userDefaults.removePersistentDomain(forName: bundleIdentifier)
        sut = CoffeeHunterDataManager()
    }
    
    override func tearDown() {
        sut = CoffeeHunterDataManager()
        userDefaults.removePersistentDomain(forName: bundleIdentifier)
        super.tearDown()
    }
    
    // MARK: - Favorites Tests
    func testAddFavorite() {
        // Given
        let shop = CoffeeShop.mock()
        
        // When
        sut.addFavorite(shop)
        
        // Then
        XCTAssertEqual(sut.favorites.count, 1)
        XCTAssertEqual(sut.favorites.first?.id, shop.id)
    }
    
    func testAddDuplicateFavorite() {
        // Given
        let shop = CoffeeShop.mock()
        
        // When
        sut.addFavorite(shop)
        sut.addFavorite(shop)
        
        // Then
        XCTAssertEqual(sut.favorites.count, 1)
    }
    
    func testRemoveFavorite() {
        // Given
        let shop = CoffeeShop.mock()
        sut.addFavorite(shop)
        
        // When
        sut.removeFavorite(shop)
        
        // Then
        XCTAssertTrue(sut.favorites.isEmpty)
    }
    
    // MARK: - Visit History Tests
    func testAddVisit() {
        // Given
        let shop = CoffeeShop.mock()
        
        // When
        sut.addVisit(shop)
        
        // Then
        XCTAssertEqual(sut.visitHistory.count, 1)
        XCTAssertEqual(sut.visitHistory.first?.shopName, shop.name)
    }
    
    func testClearVisitHistory() {
        // Given
        let shop = CoffeeShop.mock()
        sut.addVisit(shop)
        
        // When
        sut.clearVisitHistory()
        
        // Then
        XCTAssertTrue(sut.visitHistory.isEmpty)
    }
    
    // MARK: - Premium Tests
    func testSetPremiumStatus() {
        // Given
        XCTAssertFalse(sut.isPremium)
        
        // When
        sut.setPremiumStatus(true)
        
        // Then
        XCTAssertTrue(sut.isPremium)
    }
    
    // MARK: - Random Coffee Shop Tests
    func testGetRandomCoffeeShop() {
        // Given
        let userLocation = CLLocation(latitude: 0, longitude: 0)
        let nearbyShop = CoffeeShop.mock(latitude: 0.001, longitude: 0.001) // ~111m away
        let farShop = CoffeeShop.mock(latitude: 1, longitude: 1) // ~157km away
        let shops = [nearbyShop, farShop]
        
        // When
        let result = sut.getRandomCoffeeShop(from: shops, userLocation: userLocation)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, nearbyShop.id)
    }
    
    func testGenerateCoffeeRoute() {
        // Given
        let shops = [
            CoffeeShop.mock(name: "Shop 1"),
            CoffeeShop.mock(name: "Shop 2"),
            CoffeeShop.mock(name: "Shop 3"),
            CoffeeShop.mock(name: "Shop 4")
        ]
        
        // When
        let route = sut.generateCoffeeRoute(from: shops)
        
        // Then
        XCTAssertEqual(route.count, 3)
        XCTAssertTrue(Set(route.map { $0.name }).count == route.count)
    }
}
