//
//  CityWeatherEntity.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation

extension CityWeatherEntity: DomainModelHolderProtocol {    
    public func toDomainModel() -> WeatherData? {
        return WeatherData(storedEntity: self)
    }
}

extension CityWeatherEntity {
    func setup(with weatherData: WeatherData) {
        self.uuid = weatherData.uuid
        self.city = weatherData.city
        self.date = weatherData.date
        self.temp = weatherData.temp
        self.forecast = weatherData.forecast
        self.icon = weatherData.iconUrl
        self.forecastIconImg = weatherData.iconImage.pngData()
    }
}
