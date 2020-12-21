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

// MARK: Conversion - CoreData stack

extension WeatherData: DomainModelProtocol {
    public typealias StoreType = CityWeatherEntity
}

extension WeatherData {
    init?(storedEntity: StoreType) {
        guard
            let uuid = storedEntity.uuid,
            let city = storedEntity.city,
            let date = storedEntity.date,
            let forecast = storedEntity.forecast,
            let iconUrl = storedEntity.icon,
            let iconData = storedEntity.forecastIconImg,
            let iconImage = UIImage(data: iconData)
        else {
            return nil
        }
        
        self.uuid = uuid
        self.city = city
        self.date = date
        self.temp = storedEntity.temp
        self.forecast = forecast
        self.iconUrl = iconUrl
        self.iconImage = iconImage
    }
}



// MARK: Conversion - Network stack

extension WeatherData {
    init?(response: CityWeatherDataResponse, forecastIcon: UIImage) {
        guard let weatherInfo = response.weather.first else {
            return nil
        }
        self.uuid = UUID()
        self.city = response.name
        self.date = Date()
        self.temp = response.main.temp
        self.forecast = weatherInfo.main
        self.iconUrl = weatherInfo.icon
        self.iconImage = forecastIcon
    }
}
