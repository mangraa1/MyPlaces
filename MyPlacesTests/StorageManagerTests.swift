//
//  StorageManagerTests.swift
//  MyPlacesTests
//
//  Тестування CRUD-операцій Realm / StorageManager.
//  Використовується окрема in-memory конфігурація, що ізолює
//  тестові дані від виробничої бази.
//

import XCTest
import RealmSwift
@testable import MyPlaces

final class StorageManagerTests: XCTestCase {

    // Окремий in-memory Realm для кожного тест-методу.
    // Ідентифікатор унікальний завдяки `name` (повна назва тесту).
    private var testRealm: Realm!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let config = Realm.Configuration(inMemoryIdentifier: "StorageTest-\(name)")
        testRealm = try Realm(configuration: config)
        // Підміняємо Realm у StorageManager на тестовий екземпляр
        StorageManager.realm = testRealm
    }

    override func tearDownWithError() throws {
        try testRealm.write { testRealm.deleteAll() }
        testRealm = nil
        try super.tearDownWithError()
    }

    // MARK: - saveObject

    func testSaveObject_increasesCount() throws {
        let place = Place(name: "Kyiv", location: "Maidan", type: "Square", imageData: nil, rating: 4.0)
        StorageManager.saveObject(place)

        let all = testRealm.objects(Place.self)
        XCTAssertEqual(all.count, 1)
    }

    func testSaveObject_persistsCorrectName() throws {
        let place = Place(name: "Lviv Opera", location: nil, type: nil, imageData: nil, rating: 5.0)
        StorageManager.saveObject(place)

        let fetched = testRealm.objects(Place.self).first
        XCTAssertEqual(fetched?.name, "Lviv Opera")
    }

    func testSaveMultipleObjects() throws {
        let names = ["Place A", "Place B", "Place C"]
        names.forEach { name in
            StorageManager.saveObject(Place(name: name, location: nil, type: nil, imageData: nil, rating: 0))
        }

        XCTAssertEqual(testRealm.objects(Place.self).count, names.count)
    }

    // MARK: - deleteObject

    func testDeleteObject_decreasesCount() throws {
        let place = Place(name: "To Delete", location: nil, type: nil, imageData: nil, rating: 1.0)
        StorageManager.saveObject(place)
        XCTAssertEqual(testRealm.objects(Place.self).count, 1)

        StorageManager.deleteObject(place)
        XCTAssertEqual(testRealm.objects(Place.self).count, 0)
    }

    func testDeleteObject_removesCorrectItem() throws {
        let keeper = Place(name: "Keep Me", location: nil, type: nil, imageData: nil, rating: 4.0)
        let goner  = Place(name: "Delete Me", location: nil, type: nil, imageData: nil, rating: 1.0)
        StorageManager.saveObject(keeper)
        StorageManager.saveObject(goner)

        StorageManager.deleteObject(goner)

        let remaining = testRealm.objects(Place.self)
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.name, "Keep Me")
    }

    // MARK: - update (write-транзакція)

    func testUpdateObject_changesName() throws {
        let place = Place(name: "Old Name", location: nil, type: nil, imageData: nil, rating: 2.0)
        StorageManager.saveObject(place)

        try testRealm.write { place.name = "New Name" }

        let fetched = testRealm.objects(Place.self).first
        XCTAssertEqual(fetched?.name, "New Name")
    }

    func testUpdateObject_changesRating() throws {
        let place = Place(name: "Rated Place", location: nil, type: nil, imageData: nil, rating: 1.0)
        StorageManager.saveObject(place)

        try testRealm.write { place.rating = 5.0 }

        XCTAssertEqual(testRealm.objects(Place.self).first?.rating ?? 0, 5.0, accuracy: 0.001)
    }

    func testUpdateObject_changesLocation() throws {
        let place = Place(name: "Moveable", location: "Old City", type: nil, imageData: nil, rating: 0)
        StorageManager.saveObject(place)

        try testRealm.write { place.location = "New City" }

        XCTAssertEqual(testRealm.objects(Place.self).first?.location, "New City")
    }

    // MARK: - fetchObjects

    func testFetchObjects_returnsAllSaved() throws {
        for i in 1...5 {
            StorageManager.saveObject(Place(name: "Place \(i)", location: nil, type: nil, imageData: nil, rating: Double(i)))
        }

        let results = StorageManager.fetchObjects()
        XCTAssertEqual(results.count, 5)
    }

    func testFetchObjects_emptyWhenNothingSaved() throws {
        let results = StorageManager.fetchObjects()
        XCTAssertEqual(results.count, 0)
    }
}
