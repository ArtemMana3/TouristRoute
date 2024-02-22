//
//  String.swift
//  TouristRoute
//
//  Created by Artem Manakov on 22.02.2024.
//

import Foundation

extension String: Identifiable {
  public var id: String {
    return UUID().uuidString
  }
}
