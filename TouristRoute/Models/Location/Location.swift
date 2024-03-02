//
//  Location.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 13.05.2023.
//

import Foundation
import CoreLocation

struct Location: Codable, Equatable {
    let lat: Double
    let lng: Double
    
    // Computed property to get CLLocation
    var asCLLocation: CLLocation {
        return CLLocation(latitude: lat, longitude: lng)
    }
    
    var asCLLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
