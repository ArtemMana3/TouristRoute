//
//  Results.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 21.02.2024.
//

import Foundation

struct Place: Codable {
    let location: Location
    let name: String
    
    // Custom init to create a Place from the decoded JSON structures
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.location = Location(lat: latitude, lng: longitude)
    }
}
