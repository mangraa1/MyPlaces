//
//  Place.swift
//  MyPlaces
//
//  Created by mac on 08.07.2023.
//

import RealmSwift

class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?

    func saveInitialPlaces() {
        let initialPlaces = ["Royal Pizza", "Trattoria", "Osama", "Passaj", "Balu", "Montana"]

        for place in initialPlaces {

            let image = UIImage(named: place)
            guard let imageData = image?.pngData() else { return }

            let newPlace = Place()

            newPlace.name = place
            newPlace.location = "Shostka"
            newPlace.type = "Restaurant"
            newPlace.imageData = imageData

            StorageManager.saveObject(newPlace)
        }
    }
}
