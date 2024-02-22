//
//  APIResponse.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 13.05.2023.
//

import Foundation

struct APIResponse: Codable {
    let results: [PlaceResult]
}
