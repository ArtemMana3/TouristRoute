//
//  Array.swift
//  TouristRoute
//
//  Created by Artem Manakov on 03.03.2024.
//

import Foundation
import CoreLocation

extension Array where Element == Double {
    // Calculate the mean of the array
    var mean: Double {
        guard !self.isEmpty else { return 0.0 }
        let sum = self.reduce(0, +)
        return sum / Double(self.count)
    }
    
    // Calculate the standard deviation of the array
    var standardDeviation: Double {
        let mean = self.mean
        let vSum = self.reduce(0) { sum, value in
            let v = value - mean
            return sum + (v * v)
        }
        return sqrt(vSum / Double(self.count))
    }
    
    // Calculate Z-scores for the array
    func zScores() -> [Double] {
        let mean = self.mean
        let stdDev = self.standardDeviation
        return self.map { value in
            (value - mean) / stdDev
        }
    }
}
