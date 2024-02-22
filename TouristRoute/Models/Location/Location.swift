//
//  Location.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 13.05.2023.
//

import Foundation
import CoreLocation

struct Location: Codable {
    let lat: Double
    let lng: Double
    
    // Computed property to get CLLocation
    var asCLLocation: CLLocation {
        return CLLocation(latitude: lat, longitude: lng)
    }
}
