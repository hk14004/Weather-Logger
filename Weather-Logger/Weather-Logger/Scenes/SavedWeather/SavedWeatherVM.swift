//
//  SavedWeatherVM.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import Foundation

class SavedWeatherVM {
    
    private let weatherAPI: WeatherAPIProtocol
    
    init(weatherAPI: WeatherAPIProtocol = WeatherAPI()) {
        self.weatherAPI = weatherAPI
    }
    
    func saveCurrentWeather() {
        weatherAPI.getWeatherData(city: "Riga") { (data) in
            print("Save to coreData", data?.main.temp)
        }
    }
}
