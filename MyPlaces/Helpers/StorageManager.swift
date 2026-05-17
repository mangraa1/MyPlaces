//
//  StorageManager.swift
//  MyPlaces
//
//  Created by mac on 13.07.2023.
//

import RealmSwift

class StorageManager {

    // Єдина точка доступу до Realm у всьому додатку.
    // Тести можуть підмінити цю властивість на in-memory Realm,
    // не торкаючись виробничої бази даних.
    static var realm: Realm = {
        guard let instance = try? Realm() else {
            fatalError("Failed to open Realm database")
        }
        return instance
    }()

    // MARK: - CRUD

    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }

    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }

    static func fetchObjects() -> Results<Place> {
        realm.objects(Place.self)
    }
}
