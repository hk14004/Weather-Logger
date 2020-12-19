//
//  WeatherData.swift
//  Weather-Logger
//
//  Created by Hardijs on 19/12/2020.
//

import UIKit

struct WeatherData {
    let city: String
    let date: Date
    let temp: Double
    let forecast: String
    let iconUrl: String
    let iconImage: UIImage
}

// TODO: Perhaps we can init somehow better
extension WeatherData {
    init?(dataEntity: CityWeatherEntity) {
        guard
            let city = dataEntity.city,
            let date = dataEntity.date,
            let forecast = dataEntity.forecast,
            let iconUrl = dataEntity.icon,
            let iconData = dataEntity.forecastIconImg,
            let iconImage = UIImage(data: iconData)
        else {
            return nil
        }
        
        self.city = city
        self.date = date
        self.temp = dataEntity.temp
        self.forecast = forecast
        self.iconUrl = iconUrl
        self.iconImage = iconImage
    }
    
    init?(response: CityWeatherDataResponse, forecastIcon: UIImage) {
        guard let weatherInfo = response.weather.first else {
            return nil
        }
        self.city = response.name
        self.date = Date()
        self.temp = response.main.temp
        self.forecast = weatherInfo.main
        self.iconUrl = weatherInfo.icon
        self.iconImage = forecastIcon
    }
}
