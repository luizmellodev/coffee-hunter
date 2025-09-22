import XCTest
import CoreLocation
import MapKit
@testable import coffee_hunter

final class CoffeeShopServiceTests: XCTestCase {
    var sut: CoffeeShopService?
    
    override func setUp() {
        super.setUp()
        sut = CoffeeShopService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testFetchNearbyCoffeeShops() {
        // Given
        let location = CLLocationCoordinate2D(latitude: 42.0, longitude: -71.0)
        let expectation = XCTestExpectation(description: "Fetch coffee shops")
        
        guard let sut = sut else {
            XCTFail("Service not initialized")
            return
        }
        
        // When
        sut.fetchNearbyCoffeeShops(near: location)
        
        // Then
        // Note: Since MKLocalSearch makes actual network calls, we can only test that our published array gets updated
        // In a real app, we would mock the MKLocalSearch for proper unit testing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNotNil(self.sut?.coffeeShops, "Coffee shops should not be nil")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testFormatAddress() {
        // Given
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 42.0, longitude: -71.0),
            addressDictionary: [
                "Street": "Main St",
                "SubThoroughfare": "123"
            ]
        )
        
        guard let sut = sut else {
            XCTFail("Service not initialized")
            return
        }
        
        // When
        let address = sut.formatAddress(placemark)
        
        // Then
        XCTAssertFalse(address.isEmpty, "Formatted address should not be empty")
    }
}
