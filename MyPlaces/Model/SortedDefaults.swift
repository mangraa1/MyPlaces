//
//  SortedDefaults.swift
//  MyPlaces
//
//  Created by mac on 17.07.2023.
//

//TODO: - UserDefaults

/*
    In future versions of the application, it is necessary to implement saving sorting data in UserDefaults.
    It is also worth implementing saving cells in sorted form
*/

import Foundation

final class SortedDefaults {

    private enum SettingsKeys: String {
        case sortSelection
        case reversedSorting
    }

    static var sortSelection: Int! {
        get {
            return UserDefaults.standard.integer(forKey: SettingsKeys.sortSelection.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = SettingsKeys.sortSelection.rawValue
            if let selection = newValue {
                print("sort selection")
                defaults.set(selection, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }

    static var reversedSorting: String! {
        get {
            return UserDefaults.standard.string(forKey: SettingsKeys.reversedSorting.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = SettingsKeys.reversedSorting.rawValue
            if let imageName = newValue {
                print("reversed sorting")
                defaults.set(imageName, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
}
