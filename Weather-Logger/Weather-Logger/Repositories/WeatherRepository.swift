//
//  WeatherRepository.swift
//  Weather-Logger
//
//  Created by Hardijs on 19/12/2020.
//

import Foundation
import PromiseKit

protocol WeatherRepositoryProtocol: class {
    // Loading weather
    func getWeatherLogList() -> Promise<[WeatherData]>
    
    // Adding weather?
    func createWeatherLog(for location: CLLocation) -> Promise<WeatherData>
}

class WeatherRepository: WeatherRepositoryProtocol {
    
    private let weatherProvider: WeatherProviderProtocol
    
    private let weatherDao = EntityDAO<CityWeatherEntity>()
    
    init(weatherProvider: WeatherProviderProtocol = WeatherService()) {
        self.weatherProvider = weatherProvider
    }
    
    func getWeatherLogList() -> Promise<[WeatherData]> {
        Promise {
            do {
                let loadedWeather = try weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil, requestModifier: { (request) in
                    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
                })
                $0.fulfill(loadedWeather.compactMap { WeatherData(dataEntity: $0) })
            } catch (let error) {
                $0.reject(error)
            }
        }
    }
    
    func createWeatherLog(for location: CLLocation) -> Promise<WeatherData> {
        Promise { seal in
            seal.reject(NSError(domain: "createWeatherLog", code: 0, userInfo: nil))
        }
    }
}
