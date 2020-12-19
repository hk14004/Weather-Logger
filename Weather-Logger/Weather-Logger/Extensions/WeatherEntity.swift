//
//  WeatherEntity.swift
//  Weather-Logger
//
//  Created by Hardijs on 19/12/2020.
//

import Foundation

extension CityWeatherEntity {
    func setup(with weatherData: WeatherData) {
        self.city = weatherData.city
        self.date = weatherData.date
        self.temp = weatherData.temp
        self.forecast = weatherData.forecast
        self.icon = weatherData.iconUrl
        self.forecastIconImg = weatherData.iconImage.pngData()
    }
}
