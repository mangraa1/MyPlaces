//
//  PlaceModelTests.swift
//  MyPlacesTests
//
//  Тестування моделі Place: ініціалізація, значення за замовчуванням,
//  границі рейтингу та опціональні поля.
//

import XCTest
import RealmSwift
@testable import MyPlaces

final class PlaceModelTests: XCTestCase {

    // MARK: - Ініціалізація

    func testConvenienceInit_setsAllProperties() {
        let imageData = UIImage(systemName: "star")?.pngData()
        let place = Place(
            name: "Cafe Roma",
            location: "Via Veneto, Rome",
            type: "Cafe",
            imageData: imageData,
            rating: 4.5
        )

        XCTAssertEqual(place.name, "Cafe Roma")
        XCTAssertEqual(place.location, "Via Veneto, Rome")
        XCTAssertEqual(place.type, "Cafe")
        XCTAssertEqual(place.imageData, imageData)
        XCTAssertEqual(place.rating, 4.5, accuracy: 0.001)
    }

    func testConvenienceInit_withNilOptionals() {
        let place = Place(name: "Unnamed", location: nil, type: nil, imageData: nil, rating: 0.0)

        XCTAssertEqual(place.name, "Unnamed")
        XCTAssertNil(place.location)
        XCTAssertNil(place.type)
        XCTAssertNil(place.imageData)
    }

    // MARK: - Значення за замовчуванням (порожній init)

    func testDefaultInit_nameIsEmpty() {
        let place = Place()
        XCTAssertEqual(place.name, "")
    }

    func testDefaultInit_ratingIsZero() {
        let place = Place()
        XCTAssertEqual(place.rating, 0.0, accuracy: 0.001)
    }

    func testDefaultInit_optionalsAreNil() {
        let place = Place()
        XCTAssertNil(place.location)
        XCTAssertNil(place.type)
        XCTAssertNil(place.imageData)
    }

    func testDefaultInit_dateIsSetToNow() {
        let before = Date()
        let place = Place()
        let after = Date()
        XCTAssertTrue(place.date >= before)
        XCTAssertTrue(place.date <= after)
    }

    // MARK: - Граничні значення рейтингу

    func testRating_zero() {
        let place = Place(name: "T", location: nil, type: nil, imageData: nil, rating: 0.0)
        XCTAssertEqual(place.rating, 0.0, accuracy: 0.001)
    }

    func testRating_maxFive() {
        let place = Place(name: "T", location: nil, type: nil, imageData: nil, rating: 5.0)
        XCTAssertEqual(place.rating, 5.0, accuracy: 0.001)
    }

    func testRating_fractional() {
        let place = Place(name: "T", location: nil, type: nil, imageData: nil, rating: 3.7)
        XCTAssertEqual(place.rating, 3.7, accuracy: 0.001)
    }

    // MARK: - Тип моделі

    func testPlace_isRealmObject() {
        let place = Place()
        XCTAssertTrue(place is Object)
    }

    func testPlace_nameIsNotOptional() {
        // name — обов'язкове поле, має бути непорожнє після ініціалізації
        let place = Place(name: "Paris Bistro", location: nil, type: nil, imageData: nil, rating: 0)
        XCTAssertFalse(place.name.isEmpty)
    }
}
