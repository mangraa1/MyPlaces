//
//  InitialPlaces.swift
//  MyPlaces
//
//  Created by mac on 08.07.2023.
//

import Foundation

struct InitialPlaces {
    static func makePlaces() -> [Place] {
        let initialPlaces = ["Royal Pizza", "Trattoria", "Osama", "Passaj", "Balu", "Montana"]
        var places = [Place]()

        for name in initialPlaces {
            let newPlace = Place(imageName: name, name: name)
            places.append(newPlace)
        }

        return places
    }
}
