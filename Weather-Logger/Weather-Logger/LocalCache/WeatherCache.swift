//
//  WeatherCache.swift
//  Weather-Logger
//
//  Created by Hardijs on 20/12/2020.
//

import Foundation
import PromiseKit

protocol WeatherCacheProtocol {
    func getWeatherLogList() -> Promise<[WeatherData]>
    func cache(weather: WeatherData) -> Promise<Void>
    func delete(weather: WeatherData) -> Promise<Void>
}

class CoreDataWeatherCache: WeatherCacheProtocol {
    
    private let weatherDao = EntityDAO<CityWeatherEntity>()
    
    func getWeatherLogList() -> Promise<[WeatherData]> {
        Promise {
            let loadedWeather = try weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil, requestModifier: { (request) in
                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            })
            $0.fulfill(loadedWeather.compactMap { WeatherData(dataEntity: $0) })
        }
    }
    
    func cache(weather: WeatherData) -> Promise<Void> {
        Promise {
            try weatherDao.createEntity { (newEntity) in
                newEntity.setup(with: weather)
            }
            $0.fulfill(())
        }
    }
    
    func delete(weather: WeatherData) -> Promise<Void> {
        Promise {
            // TODO: Implement UUID
            let toBeDeleted = try weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil) { (reuqest) in
                reuqest.predicate = NSPredicate(format: "date == %@", weather.date as NSDate)
            }
            try weatherDao.delete(toBeDeleted)
            $0.fulfill(())
        }
    }
}
