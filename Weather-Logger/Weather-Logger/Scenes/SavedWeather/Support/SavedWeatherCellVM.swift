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
            return city + ", " + tempString
        }
    }
    let tempString: String

    let dateString: String
    
    let city: String
    
    init(weatherModel: CityWeatherEntity) {
        tempString = "\(weatherModel.temp) °C"
        if let date = weatherModel.date {
            dateString = SavedWeatherCellVM.format(date: date)
        } else {
            dateString = ""
        }
        
        city = weatherModel.city ?? ""
    }
    
    private static func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: date)
    }
}
