//
//  MainFlowUITests.swift
//  MyPlacesUITests
//
//  UI-тест базового сценарію:
//   1. Запуск застосунку.
//   2. Перехід на екран додавання місця.
//   3. Введення назви.
//   4. Збереження.
//   5. Перевірка, що новий запис з'явився в каталозі.
//
//  Додаток запускається з аргументом --uitesting, тому всі
//  Realm-операції йдуть в ізольовану in-memory базу і не
//  торкаються виробничих даних.
//

import XCTest

final class MainFlowUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Сценарій: запуск → додавання → перевірка в каталозі

    func testAddPlace_appearsInList() throws {
        // 1. Головний екран відображається
        let mainNavBar = app.navigationBars["My Places"]
        XCTAssertTrue(mainNavBar.waitForExistence(timeout: 5),
                      "Головний екран 'My Places' не з'явився")

        // 2. Натискаємо кнопку "Add" (плюс у навбарі)
        let addButton = mainNavBar.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3),
                      "Кнопка 'Add' не знайдена")
        addButton.tap()

        // 3. Форма "New Place" відкрилась
        let newPlaceNavBar = app.navigationBars["New Place"]
        XCTAssertTrue(newPlaceNavBar.waitForExistence(timeout: 3),
                      "Екран 'New Place' не відкрився")

        // 4. Вводимо назву місця
        let testPlaceName = "Test Coffee Shop"
        let nameField = app.textFields["placeName"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3),
                      "Поле 'placeName' не знайдено")
        nameField.tap()
        nameField.typeText(testPlaceName)

        // 5. Кнопка Save активується після введення назви
        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2),
                      "Кнопка Save не знайдена")
        XCTAssertTrue(saveButton.isEnabled,
                      "Кнопка Save має бути активною після введення назви")

        // 6. Зберігаємо
        saveButton.tap()

        // 7. Повернулись на головний екран
        XCTAssertTrue(mainNavBar.waitForExistence(timeout: 3),
                      "Після збереження не повернулись на 'My Places'")

        // 8. Новий запис відображається в таблиці
        let cell = app.tables["placesTable"].staticTexts[testPlaceName]
        XCTAssertTrue(cell.waitForExistence(timeout: 3),
                      "Доданий запис '\(testPlaceName)' не знайдено в каталозі")
    }

    // MARK: - Допоміжні сценарії

    func testAppLaunch_showsMainScreen() {
        XCTAssertTrue(
            app.navigationBars["My Places"].waitForExistence(timeout: 5),
            "Головний екран не відображається після запуску"
        )
    }

    func testCancelNewPlace_returnsToList() throws {
        let mainNavBar = app.navigationBars["My Places"]
        XCTAssertTrue(mainNavBar.waitForExistence(timeout: 5))

        mainNavBar.buttons["Add"].tap()

        let newPlaceNavBar = app.navigationBars["New Place"]
        XCTAssertTrue(newPlaceNavBar.waitForExistence(timeout: 3))

        // Натискаємо Cancel
        let cancelButton = app.navigationBars["New Place"].buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        cancelButton.tap()

        // Повернулись на головний список
        XCTAssertTrue(mainNavBar.waitForExistence(timeout: 3),
                      "Після Cancel не повернулись на 'My Places'")
    }

    func testSaveButton_disabledWithoutName() throws {
        app.navigationBars["My Places"].buttons["Add"].tap()

        XCTAssertTrue(app.navigationBars["New Place"].waitForExistence(timeout: 3))

        // Поле назви порожнє — Save має бути вимкнена
        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertFalse(saveButton.isEnabled,
                       "Save не повинна бути активною без введеної назви")
    }
}
