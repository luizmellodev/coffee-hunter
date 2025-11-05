import XCTest
import MapKit
import CoreLocation
import Combine
@testable import coffee_hunter

final class CoffeeHunterViewModelTests: XCTestCase {
    // MARK: - Safe Accessors
    private var viewModel: CoffeeHunterViewModel {
        guard let sut = sut else {
            XCTFail("ViewModel not initialized")
            fatalError("Test failed: ViewModel not initialized")
        }
        return sut
    }
    
    private var dataManager: MockCoffeeHunterDataManager {
        guard let manager = mockDataManager else {
            XCTFail("DataManager not initialized")
            fatalError("Test failed: DataManager not initialized")
        }
        return manager
    }
    
    private var service: MockCoffeeShopService {
        guard let service = mockCoffeeShopService else {
            XCTFail("Service not initialized")
            fatalError("Test failed: Service not initialized")
        }
        return service
    }
    
    private var bag: Set<AnyCancellable> {
        guard let bag = cancellables else {
            XCTFail("Cancellables not initialized")
            fatalError("Test failed: Cancellables not initialized")
        }
        return bag
    }
    private var sut: CoffeeHunterViewModel?
    private var mockDataManager: MockCoffeeHunterDataManager?
    private var mockCoffeeShopService: MockCoffeeShopService?
    private var cancellables: Set<AnyCancellable>?
    
    override func setUp() {
        super.setUp()
        mockDataManager = MockCoffeeHunterDataManager()
        mockCoffeeShopService = MockCoffeeShopService()
        sut = CoffeeHunterViewModel(
            dataManager: dataManager,
            coffeeShopService: service
        )
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockDataManager = nil
        mockCoffeeShopService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Favorites Tests
    
    func testToggleFavorite() {
        // Given
        let shop = CoffeeShop.mock()
        
        // When - Add to favorites
        viewModel.toggleFavorite(shop)
        
        // Then
        XCTAssertTrue(viewModel.isFavorite(shop))
        XCTAssertEqual(viewModel.favorites.count, 1)
        
        // When - Remove from favorites
        viewModel.toggleFavorite(shop)
        
        // Then
        XCTAssertFalse(viewModel.isFavorite(shop))
        XCTAssertTrue(viewModel.favorites.isEmpty)
    }
    
    // MARK: - Visit Tests
    
    func testAddVisit() {
        // Given
        let shop = CoffeeShop.mock()
        let testDate = Date()
        dataManager.dateToUseForVisits = testDate
        
        // When
        viewModel.addVisit(shop)
        
        // Then
        XCTAssertTrue(viewModel.hasVisitHistory)
        XCTAssertEqual(viewModel.visitHistory.count, 1)
        XCTAssertEqual(viewModel.visitHistory.first?.date, testDate)
    }
    
    func testHasVisitedToday() {
        // Given
        let shop = CoffeeShop.mock()
        
        // When
        viewModel.addVisit(shop)
        
        // Then
        XCTAssertTrue(viewModel.hasVisitedToday(shop))
    }
    
    func testGetVisitCount() {
        // Given
        let shop = CoffeeShop.mock()
        
        // When
        viewModel.addVisit(shop)
        viewModel.addVisit(shop)
        
        // Then
        XCTAssertEqual(viewModel.getVisitCount(for: shop), 2)
    }
    
    func testClearVisitHistory() {
        // Given
        let shop = CoffeeShop.mock()
        viewModel.addVisit(shop)
        
        // When
        viewModel.clearVisitHistory()
        
        // Then
        XCTAssertFalse(viewModel.hasVisitHistory)
        XCTAssertTrue(viewModel.visitHistory.isEmpty)
    }
    
    // MARK: - Achievement Tests
    
    func testGetAchievements() {
        // Given
        let shop1 = CoffeeShop.mock(name: "Shop 1")
        let shop2 = CoffeeShop.mock(name: "Shop 2")
        let shop3 = CoffeeShop.mock(name: "Shop 3")
        let shop4 = CoffeeShop.mock(name: "Shop 4")
        let shop5 = CoffeeShop.mock(name: "Shop 5")
        
        // When - Add visits to unlock Coffee Explorer
        viewModel.addVisit(shop1)
        viewModel.addVisit(shop2)
        viewModel.addVisit(shop3)
        viewModel.addVisit(shop4)
        viewModel.addVisit(shop5)
        
        // When - Add favorites to unlock Coffee Enthusiast
        for indice in 1...10 {
            viewModel.toggleFavorite(CoffeeShop.mock(name: "Favorite \(indice)"))
        }
        
        // When - Add multiple visits to same shop to unlock Regular Customer
        viewModel.addVisit(shop1)
        viewModel.addVisit(shop1)
        viewModel.addVisit(shop1)
        
        // Then
        let achievements = viewModel.getAchievements()
        XCTAssertEqual(achievements.count, 3)
        XCTAssertTrue(achievements.contains { $0.title == "Coffee Explorer" && $0.isUnlocked })
        XCTAssertTrue(achievements.contains { $0.title == "Coffee Enthusiast" && $0.isUnlocked })
        XCTAssertTrue(achievements.contains { $0.title == "Regular Customer" && $0.isUnlocked })
    }
    
    // MARK: - Premium Tests
    
    func testUpgradeToPremium() {
        // When
        viewModel.upgradeToPremium()
        
        // Then
        XCTAssertTrue(viewModel.isPremium)
    }
    
    // MARK: - Location Tests
    
    func testUpdateLocation() {
        // Given
        let location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let expectation = expectation(description: "Location update")
        
        // When
        viewModel.updateLocation(location)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.selectedLocation?.latitude, location.latitude)
            XCTAssertEqual(self.viewModel.selectedLocation?.longitude, location.longitude)
            XCTAssertEqual(self.service.lastFetchedLocation?.latitude, location.latitude)
            XCTAssertEqual(self.service.lastFetchedLocation?.longitude, location.longitude)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testClearCustomLocation() {
        // Given
        let customLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        viewModel.updateLocation(customLocation)
        
        // When
        viewModel.clearCustomLocation()
        
        // Then
        XCTAssertNil(viewModel.selectedLocation)
    }
}
