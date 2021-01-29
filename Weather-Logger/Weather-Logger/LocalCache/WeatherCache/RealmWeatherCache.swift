//
//  RealmWeatherCache.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation
import PromiseKit
import RealmSwift

class RealmWeatherCache {
    
    // MARK: Vars
    
    static let shared = RealmWeatherCache()
    private let realm = try! Realm()
    
    // MARK: Init
    
    private init() {}
}

// MARK: WeatherCacheProtocol

extension RealmWeatherCache: WeatherCacheProtocol {
    func getWeatherList() -> Promise<ObservableFetchResult<WeatherData>> {
        Promise {
            let logs = realm.objects(RealmWeatherData.self).sorted(byKeyPath: "date", ascending: false)
            let result = RealmObservableResult<WeatherData>(realmResult: logs)
            $0.fulfill(result)
        }
    }
    
    func cache(weather: WeatherData) -> Promise<Void> {
        Promise {
            try realm.write {
                realm.add(RealmWeatherData(weatherData: weather)!)
            }
            $0.fulfill(())
        }
    }
    
    func delete(weather: WeatherData) -> Promise<Void> {
        Promise {
            if let toBeDeleted = realm.object(ofType: RealmWeatherData.self, forPrimaryKey: weather.uuid.uuidString) {
                try realm.write {
                    realm.delete(toBeDeleted)
                }
            }
            $0.fulfill(())
        }
    }
}
