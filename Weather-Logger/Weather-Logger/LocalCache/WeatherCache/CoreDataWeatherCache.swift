//
//  CoreDataWeatherCache.swift
//  Weather-Logger
//
//  Created by Hardijs on 20/12/2020.
//

import UIKit
import CoreData
import PromiseKit

// Repository uses this object to fetch local storage data

class CoreDataWeatherCache {
    
    // MARK: Vars
    
    private let weatherDao = EntityDAO<CityWeatherEntity>()

}

// MARK: WeatherCacheProtocol

extension CoreDataWeatherCache: WeatherCacheProtocol {
    func getWeatherList() -> Promise<ObservableFetchResult<WeatherData>> {
        Promise {
            let request: NSFetchRequest<CityWeatherEntity> = CityWeatherEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            let result = try CoreDataObservableResult<WeatherData>(with: request)
            $0.fulfill(result)
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
            let toBeDeleted = try weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil) { (reuqest) in
                reuqest.predicate = NSPredicate(format: "uuid == %@", weather.uuid as CVarArg )
            }
            try weatherDao.delete(toBeDeleted)
            $0.fulfill(())
        }
    }
}
