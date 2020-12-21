//
//  WeatherData+CoreData.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import UIKit

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
