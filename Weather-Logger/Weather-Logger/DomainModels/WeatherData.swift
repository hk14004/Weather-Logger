//
//  WeatherData.swift
//  Weather-Logger
//
//  Created by Hardijs on 19/12/2020.
//

import UIKit
import CoreData

public struct WeatherData: Hashable {
    let city: String
    let date: Date
    let temp: Double
    let forecast: String
    let iconUrl: String
    let iconImage: UIImage
    let uuid: UUID
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    public static func == (lhs: WeatherData, rhs: WeatherData) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

// TODO: Perhaps we can init somehow better
extension WeatherData {
    init?(dataEntity: CityWeatherEntity) {
        guard
            let uuid = dataEntity.uuid,
            let city = dataEntity.city,
            let date = dataEntity.date,
            let forecast = dataEntity.forecast,
            let iconUrl = dataEntity.icon,
            let iconData = dataEntity.forecastIconImg,
            let iconImage = UIImage(data: iconData)
        else {
            return nil
        }
        
        self.uuid = uuid
        self.city = city
        self.date = date
        self.temp = dataEntity.temp
        self.forecast = forecast
        self.iconUrl = iconUrl
        self.iconImage = iconImage
    }
    
    init?(response: CityWeatherDataResponse, forecastIcon: UIImage) {
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



public protocol Entity {
    associatedtype StoreType: Storable
    
    func toStorable(in context: NSManagedObjectContext) -> StoreType
}

public protocol Storable {
    associatedtype EntityObject: Entity
    
    var model: EntityObject { get }
}

//3
extension Storable where Self: NSManagedObject {
    static func getOrCreateSingle(with uuid: String, from context: NSManagedObjectContext) -> Self {
            let result = single(with: uuid, from: context) ?? insertNew(in: context)
            result.setValue(uuid, forKey: "uuid")
            return result
        }
        
        static func single(with uuid: String, from context: NSManagedObjectContext) -> Self? {
            return fetch(with: uuid, from: context)?.first
        }
        
        static func insertNew(in context: NSManagedObjectContext) -> Self {
            return Self(context:context)
        }
        
        static func fetch(with uuid: String, from context: NSManagedObjectContext) -> [Self]? {
            let entityName = String(describing: Self.self)
            let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)
            fetchRequest.fetchLimit = 1

            let result: [Self]? = try? context.fetch(fetchRequest)
            
            return result
        }
}

//2
extension CityWeatherEntity: Storable {
    public var model: WeatherData
    {
        get {
            return WeatherData(dataEntity: self)!
        }
    }
}

//1
extension WeatherData: Entity {
    public func toStorable(in context: NSManagedObjectContext) -> CityWeatherEntity {
        
        return CityWeatherEntity()
    }
}
