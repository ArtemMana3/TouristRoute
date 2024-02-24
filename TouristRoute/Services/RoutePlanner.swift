//
//  RoutePlanner.swift
//  TouristRoute
//
//  Created by Artem Manakov on 24.02.2024.
//

import Foundation
import CoreLocation

class RoutePlanner {
    let dailyLimitKm: Double = 10.0
    var locations: [Location]
    let startingPoint: Location

    init(locations: [Location], startingPoint: Location) {
        self.locations = locations
        self.startingPoint = startingPoint
    }

    func planRoute(for days: Int) -> [[Location]] {
        var routes: [[Location]] = Array(repeating: [], count: days)
        var currentLocation = startingPoint
        var remainingLocations = locations

        for day in 0..<days {
            var dailyDistance: Double = 0.0
            var dayRoute: [Location] = []

            while !remainingLocations.isEmpty {
                if let nextLocation = findNextLocation(currentLocation: currentLocation, remainingLocations: remainingLocations, dailyDistance: dailyDistance) {
                    let distance = distanceBetween(currentLocation.asCLLocation.coordinate, nextLocation.asCLLocation.coordinate)
                    dailyDistance += distance
                    if dailyDistance > dailyLimitKm {
                        break
                    }

                    dayRoute.append(nextLocation)
                    currentLocation = nextLocation
                    remainingLocations.removeAll { $0.lat == currentLocation.lat }
                } else {
                    break
                }
            }

            routes[day] = dayRoute
            if remainingLocations.isEmpty {
                break
            }
        }

        return routes
    }

    private func findNextLocation(currentLocation: Location, remainingLocations: [Location], dailyDistance: Double) -> Location? {
        let sortedLocations = remainingLocations.sorted { (loc1: Location, loc2: Location) -> Bool in
            let distance1 = distanceBetween(loc1.asCLLocation.coordinate, currentLocation.asCLLocation.coordinate)
            let distance2 = distanceBetween(loc2.asCLLocation.coordinate, currentLocation.asCLLocation.coordinate)
            return distance1 < distance2
        }

        for location in sortedLocations {
            let distance = distanceBetween(currentLocation.asCLLocation.coordinate, location.asCLLocation.coordinate)
            if dailyDistance + distance <= dailyLimitKm {
                return location
            }
        }

        return nil
    }

    private func distanceBetween(_ coordinate1: CLLocationCoordinate2D, _ coordinate2: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
        return location1.distance(from: location2) / 1000 // Convert to kilometers
    }
}
