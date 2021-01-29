//
//  SavedWeatherCellVM.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import Foundation

class SavedWeatherCellVM {
    
    // MARK: Variables
    
    private let weatherData: WeatherData
    
    var title: String {
        "\(weatherData.city), \(Measurement(value: weatherData.temp, unit: UnitTemperature.celsius))"
    }

    var subtitle: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: weatherData.date)
    }
    
    // MARK: Init
    
    init(weatherModel: WeatherData) {
        weatherData = weatherModel
    }
}
