//
//  CityWeatherEntity.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation

extension CityWeatherEntity: DomainHolderProtocol {    
    public func toDomainModel() -> WeatherData {
        return WeatherData(dataEntity: self)!
    }
}
