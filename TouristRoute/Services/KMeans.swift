//
//  KMeans.swift
//  TouristRoute
//
//  Created by Artem Manakov on 26.02.2024.
//

import Foundation
import CoreLocation

class KMeans {
    var locations: [Location]
    
    init(locations: [Location]) {
        self.locations = locations
    }
    
    func findBestClustering(intoGroups k: Int, iterations: Int = 100) -> [[Location]] {
        var bestClusters: [[Location]] = []
        var bestDistancesInClusters: [Double] = []
        
        for _ in 0..<iterations {
            let (clusters, newDistancesInClusters) = clusterLocations(intoGroups: k)
            
            if (bestDistancesInClusters.count == 0) {
                bestDistancesInClusters = newDistancesInClusters
                bestClusters = clusters
                continue
            }
            
            if (isFirstArrayBetter(firstArray: newDistancesInClusters, secondArray: bestDistancesInClusters)) {
                compareAndUpdateBestClusters(currentClusters: clusters, currentScore: newDistancesInClusters, bestClusters: &bestClusters, bestScore: &bestDistancesInClusters)
            }
        }
        print(bestDistancesInClusters)

        return (bestClusters)
    }
    
    func compareAndUpdateBestClusters(currentClusters: [[Location]], currentScore: [Double], bestClusters: inout [[Location]], bestScore: inout [Double]) {
        // Create tuples of (score, cluster) for current and best, then sort them by score.
        
        if (bestScore.max()! - bestScore.min()!) > 1500 {
            bestClusters = currentClusters
            bestScore = currentScore
        }
        
        let currentScoreClusterPairs = zip(currentScore, currentClusters).sorted { $0.0 < $1.0 }
        let bestScoreClusterPairs = zip(bestScore, bestClusters).sorted { $0.0 < $1.0 }
        
        // Extract the sorted scores and clusters back into separate arrays
        let (sortedCurrentScores, sortedCurrentClusters) = currentScoreClusterPairs.unzip()
        let (sortedBestScores, sortedBestClusters) = bestScoreClusterPairs.unzip()
        
        // Compare the sorted scores
        let differences = zip(sortedCurrentScores, sortedBestScores).map { abs($0 - $1) }
        for (index, difference) in differences.enumerated() {
            if difference < 300 {
                // If scores are similar, check if any of the current clusters is larger in size
                if sortedCurrentClusters[index].count > sortedBestClusters[index].count {
                    // Update 'bestClusters' and 'bestScore' if any current cluster is larger
                    bestClusters = currentClusters
                    bestScore = currentScore
                    break // Exit the loop after updating
                }
            }
        }

    }
    
    func isFirstArrayBetter(firstArray: [Double], secondArray: [Double]) -> Bool {
        // Ensure both arrays have more than one element for meaningful comparison
        guard firstArray.count > 1, secondArray.count > 1 else { return false }
        
        // Calculate the maximum difference within each array
        let firstArrayMaxDifference = firstArray.max()! - firstArray.min()!
        let secondArrayMaxDifference = secondArray.max()! - secondArray.min()!
        
        // Determine if the first array has a smaller maximum difference
        return firstArrayMaxDifference < secondArrayMaxDifference
    }


    
    private func clusterLocations(intoGroups k: Int) -> ([[Location]], [Double]) {
        guard !locations.isEmpty, k > 0 else { return ([], [0.0]) }
        
        let centroids = (0..<k).compactMap { _ in locations.randomElement()?.asCLLocationCoordinate2D }
        var clusters: [[Location]] = Array(repeating: [], count: k)
        var totalDistancesInClusters: [Double] = []
        
        clusters = Array(repeating: [], count: k)
        
        for location in locations {
            let nearestCentroidIndex = nearestCentroid(for: location, centroids: centroids)
            clusters[nearestCentroidIndex].append(location)
        }
        
        totalDistancesInClusters = evaluateClusters(clusters: clusters)
        
        return (clusters, totalDistancesInClusters)
    }
    
    private func nearestCentroid(for location: Location, centroids: [CLLocationCoordinate2D]) -> Int {
        var nearestIndex = 0
        var smallestDistance = Double.greatestFiniteMagnitude
        
        for (index, centroid) in centroids.enumerated() {
            let distance = location.asCLLocation.distance(from: CLLocation(latitude: centroid.latitude, longitude: centroid.longitude))
            if distance < smallestDistance {
                nearestIndex = index
                smallestDistance = distance
            }
        }
        
        return nearestIndex
    }
    
    private func evaluateClusters(clusters: [[Location]]) -> [Double] {
        let totalDistances = clusters.map { cluster -> Double in
            return greedyTSPDistance(forCluster: cluster)
        }
        return totalDistances
    }
    
    private func distanceBetween(_ start: Location, _ end: Location) -> Double {
        let startCoord = CLLocation(latitude: start.lat, longitude: start.lng)
        let endCoord = CLLocation(latitude: end.lat, longitude: end.lng)
        return startCoord.distance(from: endCoord)
    }
    
    func greedyTSPDistance(forCluster cluster: [Location]) -> Double {
        guard cluster.count > 1 else { return 0 }
        
        var visited: [Bool] = Array(repeating: false, count: cluster.count)
        var totalDistance: Double = 0
        var currentLocationIndex = 0
        visited[currentLocationIndex] = true
        
        for _ in 1..<cluster.count {
            var nearestDistance = Double.greatestFiniteMagnitude
            var nearestIndex = -1
            
            for (index, location) in cluster.enumerated() where !visited[index] {
                let distance = distanceBetween(cluster[currentLocationIndex], location)
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestIndex = index
                }
            }
            
            visited[nearestIndex] = true
            totalDistance += nearestDistance
            currentLocationIndex = nearestIndex
        }
        
        totalDistance += distanceBetween(cluster[currentLocationIndex], cluster[0])
        
        return totalDistance
    }
}

extension Sequence {
    func unzip<T, U>() -> ([T], [U]) where Element == (T, U) {
        var firsts: [T] = []
        var seconds: [U] = []
        for (first, second) in self {
            firsts.append(first)
            seconds.append(second)
        }
        return (firsts, seconds)
    }
}
