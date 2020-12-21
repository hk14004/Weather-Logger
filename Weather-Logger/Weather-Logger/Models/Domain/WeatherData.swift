//
//  WeatherData.swift
//  Weather-Logger
//
//  Created by Hardijs on 19/12/2020.
//

import UIKit
import CoreData

// Domain level data object used throughout app to abstract data sources

public struct WeatherData {
    let uuid: UUID
    let city: String
    let date: Date
    let temp: Double
    let forecast: String
    let iconUrl: String
    let iconImage: UIImage
}

// MARK: Hashable - To be diff-able data source

extension WeatherData: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
