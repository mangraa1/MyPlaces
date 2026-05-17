//
//  SearchSortTests.swift
//  MyPlacesTests
//
//  Тестування пошуку (фільтрація за name/location) та сортування
//  (за name та за date) — ті самі NSPredicate і keyPath, що
//  використовує MainViewController.
//

import XCTest
import RealmSwift
@testable import MyPlaces

final class SearchSortTests: XCTestCase {

    private var testRealm: Realm!

    // Фіксований набір місць для тестів
    private let fixtures: [(name: String, location: String, type: String, rating: Double)] = [
        ("Cafe Roma",   "Rome",      "Cafe",  4.0),
        ("Bar Barca",   "Barcelona", "Bar",   3.5),
        ("Hotel Kyiv",  "Kyiv",      "Hotel", 4.8),
        ("Museum Paris","Paris",     "Museum",4.2),
    ]

    override func setUpWithError() throws {
        try super.setUpWithError()
        let config = Realm.Configuration(inMemoryIdentifier: "SearchSortTest-\(name)")
        testRealm = try Realm(configuration: config)

        try testRealm.write {
            fixtures.forEach { f in
                testRealm.add(Place(name: f.name, location: f.location, type: f.type, imageData: nil, rating: f.rating))
            }
        }
    }

    override func tearDownWithError() throws {
        try testRealm.write { testRealm.deleteAll() }
        testRealm = nil
        try super.tearDownWithError()
    }

    // MARK: - Пошук за name

    func testSearch_byName_caseInsensitive() {
        let results = testRealm.objects(Place.self)
            .filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", "cafe", "cafe")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Cafe Roma")
    }

    func testSearch_byName_uppercased() {
        let results = testRealm.objects(Place.self)
            .filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", "HOTEL", "HOTEL")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Hotel Kyiv")
    }

    func testSearch_byName_partialMatch() {
        // "Mu" відповідає "Museum Paris"
        let results = testRealm.objects(Place.self)
            .filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", "mu", "mu")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Museum Paris")
    }

    // MARK: - Пошук за location

    func testSearch_byLocation_exactCity() {
        let results = testRealm.objects(Place.self)
            .filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", "kyiv", "kyiv")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.location, "Kyiv")
    }

    func testSearch_byLocation_caseInsensitive() {
        let results = testRealm.objects(Place.self)
            .filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", "ROME", "ROME")
        XCTAssertEqual(results.count, 1)
    }

    func testSearch_matchesNameOrLocation() {
        // "bar" є і в назві "Bar Barca", і в місті "Barcelona"
        // → обидва поля пошуку вказують на один і той самий запис
        let results = testRealm.objects(Place.self)
            .filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", "bar", "bar")
        XCTAssertEqual(results.count, 1)
    }

    func testSearch_noResults_whenQueryUnmatched() {
        let results = testRealm.objects(Place.self)
            .filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", "zzznomatch", "zzznomatch")
        XCTAssertEqual(results.count, 0)
    }

    func testSearch_noResultsForEmptyString() {
        // Realm (на відміну від SQLite) повертає 0 результатів
        // для предиката CONTAINS з порожнім рядком.
        // В застосунку цей стан перехоплює isFiltering = false,
        // тому filterContentForSearchText("") ніколи не викликається.
        let results = testRealm.objects(Place.self)
            .filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", "", "")
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Сортування за name

    func testSort_byName_ascending() {
        let sorted = testRealm.objects(Place.self).sorted(byKeyPath: "name", ascending: true)
        let names = sorted.map { $0.name }
        XCTAssertEqual(Array(names), ["Bar Barca", "Cafe Roma", "Hotel Kyiv", "Museum Paris"])
    }

    func testSort_byName_descending() {
        let sorted = testRealm.objects(Place.self).sorted(byKeyPath: "name", ascending: false)
        XCTAssertEqual(sorted.first?.name, "Museum Paris")
        XCTAssertEqual(sorted.last?.name, "Bar Barca")
    }

    // MARK: - Сортування за date

    func testSort_byDate_ascending_hasAllElements() {
        let sorted = testRealm.objects(Place.self).sorted(byKeyPath: "date", ascending: true)
        XCTAssertEqual(sorted.count, fixtures.count)
    }

    func testSort_byDate_descendingEqualsAscendingReversed() {
        let asc  = Array(testRealm.objects(Place.self).sorted(byKeyPath: "date", ascending: true).map { $0.name })
        let desc = Array(testRealm.objects(Place.self).sorted(byKeyPath: "date", ascending: false).map { $0.name })
        XCTAssertEqual(asc, desc.reversed())
    }

    // MARK: - Сортування за rating

    func testSort_byRating_descending_highestFirst() {
        let sorted = testRealm.objects(Place.self).sorted(byKeyPath: "rating", ascending: false)
        // Найвищий рейтинг — Hotel Kyiv (4.8)
        XCTAssertEqual(sorted.first?.name, "Hotel Kyiv")
    }

    func testSort_byRating_ascending_lowestFirst() {
        let sorted = testRealm.objects(Place.self).sorted(byKeyPath: "rating", ascending: true)
        // Найнижчий рейтинг — Bar Barca (3.5)
        XCTAssertEqual(sorted.first?.name, "Bar Barca")
    }
}
