//
//  WeatherData+Realm.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import UIKit

// MARK: Conversion - Realm stack

extension WeatherData {
    init?(realmEntity: RealmWeatherData) {
        let city = realmEntity.city
        let date = realmEntity.date
        let forecast = realmEntity.forecast
        let iconUrl = realmEntity.iconUrl
        let iconData = realmEntity.iconImage
    
        guard
            let iconImage = UIImage(data: iconData),
            let uuid = UUID(uuidString: realmEntity.uuid)
        else {
            return nil
        }
        
        self.uuid = uuid
        self.city = city
        self.date = date
        self.temp = realmEntity.temp
        self.forecast = forecast
        self.iconUrl = iconUrl
        self.iconImage = iconImage
    }
}
