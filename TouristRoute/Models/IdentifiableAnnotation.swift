//
//  IdentifiableAnnotation.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 21.02.2024.
//

import Foundation
import MapKit

struct IdentifiableAnnotation: Identifiable {
    let id: UUID
    let title: String
    let photoReference: String

    init(title: String, photoReference: String) {
        self.id = UUID() // Provide a unique identifier
        self.title = title
        self.photoReference = photoReference
    }
}
