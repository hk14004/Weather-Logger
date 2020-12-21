//
//  NSCacheWeatherCache.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation
import PromiseKit

class NSCacheWeatherCache {
    
    // MARK: Types
    
    typealias KeyType = UUID
    
    // MARK: Vars
    
    static let shared = NSCacheWeatherCache()
    private let cache = Cache<KeyType, WeatherData>()
    
    // MARK: Init
    
    private init() {}
}

// MARK: WeatherCacheProtocol

extension NSCacheWeatherCache: WeatherCacheProtocol {
    func getWeatherList() -> Promise<ObservableFetchResult<WeatherData>> {
        Promise {
            let sortedBy: ((WeatherData, WeatherData) throws -> Bool) = { $0.date > $1.date }
            $0.fulfill(NSCacheObservableResult<KeyType,WeatherData>(with: cache, sortedBy: sortedBy))
        }
    }
    
    func cache(weather: WeatherData) -> Promise<Void> {
        Promise {
            cache.insert(weather, forKey: weather.uuid)
            $0.fulfill(())
        }
    }
    
    func delete(weather: WeatherData) -> Promise<Void> {
        Promise {
            cache.removeValue(forKey: weather.uuid)
            $0.fulfill(())
        }
    }
}
