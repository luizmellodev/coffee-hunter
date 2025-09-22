import XCTest
import CoreLocation
import MapKit
@testable import coffee_hunter

final class CoffeeHunterViewModelTests: XCTestCase {
    var sut: CoffeeHunterViewModel?
    
    override func setUp() {
        super.setUp()
        sut = CoffeeHunterViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testToggleFavorite() {
        // Given
        let coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Test Coffee"
        
        let shop = CoffeeShop(
            name: "Test Coffee",
            rating: 4.5,
            distance: 0.5,
            address: "123 Test St",
            coordinates: coordinates,
            mapItem: mapItem
        )
        
        guard let sut = sut else {
            XCTFail("ViewModel not initialized")
            return
        }
        
        let expectation1 = XCTestExpectation(description: "Add to favorites")
        let expectation2 = XCTestExpectation(description: "Remove from favorites")
        
        // When - Add to favorites
        sut.toggleFavorite(shop)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(sut.isFavorite(shop), "Shop should be favorite after adding")
            expectation1.fulfill()
            
            // When - Remove from favorites
            sut.toggleFavorite(shop)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then
                XCTAssertFalse(sut.isFavorite(shop), "Shop should not be favorite after removing")
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 1.0)
    }
    
    func testNavigateToMapWithShop() {
        // Given
        let coordinates = CLLocationCoordinate2D(latitude: 42.0, longitude: -71.0)
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Test Coffee"
        
        let shop = CoffeeShop(
            name: "Test Coffee",
            rating: 4.5,
            distance: 0.5,
            address: "123 Test St",
            coordinates: coordinates,
            mapItem: mapItem
        )
        
        guard let sut = sut else {
            XCTFail("ViewModel not initialized")
            return
        }
        
        // When
        sut.navigateToMapWithShop(shop)
        
        // Then
        XCTAssertEqual(sut.selectedTab, 1, "Should switch to map tab")
        XCTAssertEqual(sut.selectedLocation?.latitude, shop.coordinates.latitude, "Should update selected location")
        XCTAssertEqual(sut.selectedLocation?.longitude, shop.coordinates.longitude, "Should update selected location")
        
        // Wait for the async selection of shop
        let expectation = XCTestExpectation(description: "Shop selection")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.sut?.selectedCoffeeShop?.id, shop.id, "Should select the shop")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateLocation() {
        // Given
        let location = CLLocationCoordinate2D(latitude: 42.0, longitude: -71.0)
        
        guard let sut = sut else {
            XCTFail("ViewModel not initialized")
            return
        }
        
        // When
        sut.updateLocation(location)
        
        // Then
        XCTAssertEqual(sut.selectedLocation?.latitude, location.latitude, "Should update selected location latitude")
        XCTAssertEqual(sut.selectedLocation?.longitude, location.longitude, "Should update selected location longitude")
    }
    
    func testClearVisitHistory() {
        // Given
        let coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Test Coffee"
        
        let shop = CoffeeShop(
            name: "Test Coffee",
            rating: 4.5,
            distance: 0.5,
            address: "123 Test St",
            coordinates: coordinates,
            mapItem: mapItem
        )
        guard let sut = sut else {
            XCTFail("ViewModel not initialized")
            return
        }
        
        let expectation = XCTestExpectation(description: "Clear visit history")
        
        sut.dataManager.addVisit(shop)
        
        // When
        sut.clearVisitHistory()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(sut.dataManager.visitHistory.isEmpty, "Visit history should be empty after clearing")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRestorePurchases() {
        // Given
        let expectation = XCTestExpectation(description: "Restore purchases completion")
        
        guard let sut = sut else {
            XCTFail("ViewModel not initialized")
            return
        }
        
        // When
        sut.restorePurchases { success in
            // Then
            XCTAssertFalse(success, "Restore purchases should return false in current implementation")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
