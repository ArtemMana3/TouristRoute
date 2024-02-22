//
//  PlaceResult.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 13.05.2023.
//

import Foundation

struct PlaceResult: Codable {
    let geometry: Geometry
    let name: String
    let photos: [Photo]
}
