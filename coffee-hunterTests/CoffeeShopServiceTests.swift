import XCTest
import MapKit
import CoreLocation
import Combine
@testable import coffee_hunter

final class CoffeeShopServiceTests: XCTestCase {
    var sut = CoffeeShopService()
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        sut = CoffeeShopService()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testFormatAddress() {
        // Given
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            addressDictionary: [
                "Street": "Test Street",
                "SubThoroughfare": "123"
            ]
        )
        
        // When
        let formattedAddress = sut.formatAddress(placemark)
        
        // Then
        XCTAssertEqual(formattedAddress, "123 Test Street")
    }
    
    func testFormatAddressWithMissingNumber() {
        // Given
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            addressDictionary: [
                "Street": "Test Street"
            ]
        )
        
        // When
        let formattedAddress = sut.formatAddress(placemark)
        
        // Then
        XCTAssertEqual(formattedAddress, "Test Street")
    }
    
    func testFormatAddressWithMissingStreet() {
        // Given
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            addressDictionary: [
                "SubThoroughfare": "123"
            ]
        )
        
        // When
        let formattedAddress = sut.formatAddress(placemark)
        
        // Then
        XCTAssertEqual(formattedAddress, "123")
    }
    
    func testFetchNearbyCoffeeShops() {
        // Given
        let expectation = expectation(description: "Fetch coffee shops")
        let location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // When
        sut.fetchNearbyCoffeeShops(near: location)
        
        sut.$coffeeShops
            .sink { shops in
                if !shops.isEmpty {
                    // Then
                    XCTAssertTrue(shops.allSatisfy { $0.distance <= 150 })
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
    }
}
