//
//  WeatherData+CoreData.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import UIKit

// MARK: Conversion - CoreData stack

extension WeatherData: DomainModelProtocol {
    public typealias StoreType = CoreDataWeather
}

extension WeatherData {
    init?(coreDataEntity: StoreType) {
        guard
            let uuid = coreDataEntity.uuid,
            let city = coreDataEntity.city,
            let date = coreDataEntity.date,
            let forecast = coreDataEntity.forecast,
            let iconUrl = coreDataEntity.icon,
            let iconData = coreDataEntity.forecastIconImg,
            let iconImage = UIImage(data: iconData)
        else {
            return nil
        }
        
        self.uuid = uuid
        self.city = city
        self.date = date
        self.temp = coreDataEntity.temp
        self.forecast = forecast
        self.iconUrl = iconUrl
        self.iconImage = iconImage
    }
}
