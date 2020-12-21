//
//  CityWeatherEntity.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation

extension CityWeatherEntity: Storable {
    public var model: WeatherData {
        get {
            return WeatherData(dataEntity: self)!
        }
    }
}
