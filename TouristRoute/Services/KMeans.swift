//
//  KMeans.swift
//  TouristRoute
//
//  Created by Artem Manakov on 26.02.2024.
//

import Foundation
import CoreLocation

class KMeans {
    var dailyLimitKm: Double = 10.0
    var locations: [Location]
    let startingPoint: Location
    
    init(locations: [Location], startingPoint: Location, dailyLimitKm: Double) {
        self.locations = locations
        self.startingPoint = startingPoint
        self.dailyLimitKm = dailyLimitKm
    }
    
    // New K-means clustering method
    func clusterLocations(intoGroups k: Int) -> [[Location]] {
        guard !locations.isEmpty, k > 0 else { return [] }

        // 1. Initialize k centroids randomly
        var centroids: [CLLocationCoordinate2D] = (0..<k).compactMap { _ in
            locations.randomElement()?.asCLLocationCoordinate2D
        }

        var clusters: [[Location]] = Array(repeating: [], count: k)
        var previousCentroids: [CLLocationCoordinate2D] = []

        // Repeat until centroids do not change
        repeat {
            // Clear previous clusters
            clusters = Array(repeating: [], count: k)
            previousCentroids = centroids
            
            // 2. Assign each location to the nearest centroid
            for location in locations {
                let nearestCentroidIndex = nearestCentroid(for: location, centroids: centroids)
                clusters[nearestCentroidIndex].append(location)
            }

            // 3. Update centroids to be the center of assigned locations
            centroids = clusters.map { cluster in
                let meanLat = cluster.map { $0.lat }.reduce(0.0, +) / Double(cluster.count)
                let meanLng = cluster.map { $0.lng }.reduce(0.0, +) / Double(cluster.count)
                return CLLocationCoordinate2D(latitude: meanLat, longitude: meanLng)
            }
            
        } while !centroidsEqual(centroids, previousCentroids)

        return clusters
    }

    private func nearestCentroid(for location: Location, centroids: [CLLocationCoordinate2D]) -> Int {
        var nearestDistance = Double.greatestFiniteMagnitude
        var nearestIndex = 0

        for (index, centroid) in centroids.enumerated() {
            let distance = location.asCLLocation.distance(from: CLLocation(latitude: centroid.latitude, longitude: centroid.longitude))
            if distance < nearestDistance {
                nearestDistance = distance
                nearestIndex = index
            }
        }

        return nearestIndex
    }

    private func centroidsEqual(_ centroids: [CLLocationCoordinate2D], _ previousCentroids: [CLLocationCoordinate2D]) -> Bool {
        return zip(centroids, previousCentroids).allSatisfy { centroid, previousCentroid in
            return centroid.latitude == previousCentroid.latitude && centroid.longitude == previousCentroid.longitude
        }
    }
}
