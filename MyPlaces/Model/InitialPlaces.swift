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

        for place in initialPlaces {
            let newPlace = Place(name: place, location: "Shostka", type: "Restaurant",image: nil, restaurantImage: place)
            places.append(newPlace)
        }

        return places
    }
}
