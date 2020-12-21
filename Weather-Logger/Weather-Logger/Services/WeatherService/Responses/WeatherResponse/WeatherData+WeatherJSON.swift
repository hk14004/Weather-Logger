//
//  WeatherData+WeatherJSON.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import UIKit

// MARK: Conversion - Network stack

extension WeatherData {
    init?(response: WeatherJSONResponse, forecastIcon: UIImage) {
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
