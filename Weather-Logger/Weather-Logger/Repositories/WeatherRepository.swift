//
//  WeatherRepository.swift
//  Weather-Logger
//
//  Created by Hardijs on 19/12/2020.
//

import Foundation
import PromiseKit

protocol WeatherRepositoryProtocol: class {
    func getWeatherLogList() -> Promise<[WeatherData]>
    func createWeatherLog(for location: CLLocation) -> Promise<WeatherData>
    func delete(weatherLog: WeatherData) -> Promise<Void>
}

class WeatherRepository: WeatherRepositoryProtocol {
    
    private let weatherProvider: WeatherProviderProtocol
    
    private let weatherDao = EntityDAO<CityWeatherEntity>()
    
    init(weatherProvider: WeatherProviderProtocol = WeatherService()) {
        self.weatherProvider = weatherProvider
    }
    
    func getWeatherLogList() -> Promise<[WeatherData]> {
        Promise {
            let loadedWeather = try weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil, requestModifier: { (request) in
                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            })
            $0.fulfill(loadedWeather.compactMap { WeatherData(dataEntity: $0) })
        }
    }
    
    func createWeatherLog(for location: CLLocation) -> Promise<WeatherData> {
        let queue = DispatchQueue.global(qos: .userInitiated)
        return Promise { seal in
            firstly {
                weatherProvider.getWeatherData(location: location)
            }.then(on: queue) { (weatherResponse) -> Promise<(CityWeatherDataResponse, UIImage)> in
                guard let iconUrl = weatherResponse.weather.first?.icon else {
                    throw NSError(domain: "API did not return icon url", code: 0, userInfo: nil)
                }
                return self.weatherProvider.getForecastIcon(with: iconUrl).map { (weatherResponse, $0) }
            }.done(on: queue) { (weatherResponse, image) in
                guard let weatherData = WeatherData(response: weatherResponse, forecastIcon: image) else {
                    throw NSError(domain: "Could not create weather data from response", code: 0, userInfo: nil)
                }
                try self.weatherDao.createEntity { (newEntity) in
                    newEntity.setup(with: weatherData)
                }
                seal.fulfill(weatherData)
            }.catch { (error) in
                seal.reject(error)
            }
        }
    }
    
    func delete(weatherLog: WeatherData) -> Promise<Void> {
        Promise {
            // TODO: Implement UUID
            let toBeDeleted = try weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil) { (reuqest) in
                reuqest.predicate = NSPredicate(format: "date == %@", weatherLog.date as NSDate)
            }
            try weatherDao.delete(toBeDeleted)
            $0.fulfill(())
        }
    }
}
