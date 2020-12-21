//
//  RealmWeatherData.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation
import RealmSwift

public class RealmWeatherData: Object {
    
    @objc dynamic var uuid: String
    @objc dynamic var city: String
    @objc dynamic var date: Date
    @objc dynamic var temp: Double
    @objc dynamic var forecast: String
    @objc dynamic var iconUrl: String
    @objc dynamic var iconImage: Data
    
    override init() {
        self.uuid = ""
        self.city = ""
        self.date = Date()
        self.temp = 0
        self.forecast = ""
        self.iconUrl = ""
        self.iconImage = Data(repeating: 0, count: 0)
        
    }
    init(uuid: String, city: String, date: Date, temp: Double, forecast: String, iconUrl: String, iconImage: Data) {
        self.uuid = uuid
        self.city = city
        self.date = date
        self.temp = temp
        self.forecast = forecast
        self.iconUrl = iconUrl
        self.iconImage = iconImage
    }
    
    init?(weatherData: WeatherData) {
        self.uuid = weatherData.uuid.uuidString
        self.city = weatherData.city
        self.date = weatherData.date
        self.temp = weatherData.temp
        self.forecast = weatherData.forecast
        self.iconUrl = weatherData.iconUrl
        guard let data = weatherData.iconImage.pngData() else {
            return nil
        }
        self.iconImage = data
        
    }
    
    public override static func primaryKey() -> String? {
        return "uuid"
    }
}

extension RealmWeatherData: DomainModelHolderProtocol {
    public func toDomainModel() -> WeatherData? {
        return WeatherData(realmEntity: self)
    }
}
