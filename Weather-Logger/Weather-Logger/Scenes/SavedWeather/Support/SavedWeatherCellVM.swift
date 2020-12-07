//
//  SavedWeatherCellVM.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import Foundation

class SavedWeatherCellVM {
    
    var cellTitle: String {
        get {
            var title = ""
            if !tempString.isEmpty {
                title += tempString
            }
            
            if !city.isEmpty {
                title = "\(city), " + title
            }
            return title
        }
    }
    let tempString: String

    let dateString: String
    
    let city: String
    
    init(weatherModel: CityWeatherEntity) {
        let tempMeasurement = Measurement(value: weatherModel.temp, unit: UnitTemperature.celsius)
        tempString = "\(tempMeasurement)"
        if let date = weatherModel.date {
            dateString = SavedWeatherCellVM.formatWeather(date: date)
        } else {
            dateString = ""
        }
        
        city = weatherModel.city ?? ""
    }
    
    private static func formatWeather(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: date)
    }
}
