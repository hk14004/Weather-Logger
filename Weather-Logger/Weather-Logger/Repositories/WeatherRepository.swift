//
//  WeatherRepository.swift
//  Weather-Logger
//
//  Created by Hardijs on 19/12/2020.
//

import Foundation
import PromiseKit

// ViewModels use this protocol to manipulate with data

protocol WeatherRepositoryProtocol {
    func insertWeatherLog(for location: CLLocation) -> Promise<WeatherData>
    func delete(weather: WeatherData) -> Promise<Void>
    func getWeatherList() -> Promise<ObservableFetchResult<WeatherData>>
}

class WeatherRepository {
    
    // MARK: Vars
    
    private let remoteWeatherProvider: RemoteWeatherProviderProtocol
    
    private let localWeatherCache: WeatherCacheProtocol
    
    // MARK: Init
    
    init(weatherProvider: RemoteWeatherProviderProtocol = WeatherService(),
         localWeatherCache: WeatherCacheProtocol = RealmWeatherCache.shared) {
        self.remoteWeatherProvider = weatherProvider
        self.localWeatherCache = localWeatherCache
    }
}

// MARK: WeatherRepositoryProtocol

extension WeatherRepository: WeatherRepositoryProtocol {
    func getWeatherList() -> Promise<ObservableFetchResult<WeatherData>> {
        return localWeatherCache.getWeatherList()
    }
    
    func insertWeatherLog(for location: CLLocation) -> Promise<WeatherData> {
        let queue = DispatchQueue.global(qos: .userInitiated)
        return Promise { seal in
            firstly {
                remoteWeatherProvider.getWeatherData(location: location)
            }.then(on: queue) { (weatherResponse) -> Promise<(WeatherJSONResponse, UIImage)> in
                guard let iconUrl = weatherResponse.weather.first?.icon else {
                    throw NSError(domain: "API did not return icon url", code: 0, userInfo: nil)
                }
                return self.remoteWeatherProvider.getForecastIcon(with: iconUrl).map { (weatherResponse, $0) }
            }.then { (weatherResponse, image) -> Promise<WeatherData> in
                guard let weatherData = WeatherData(response: weatherResponse, forecastIcon: image) else {
                    throw NSError(domain: "Could not create weather data from response", code: 0, userInfo: nil)
                }
                return self.localWeatherCache.cache(weather: weatherData).map { (weatherData) }
            }.done(on: queue) { (weatherData) in
                seal.fulfill(weatherData)
            }.catch { (error) in
                seal.reject(error)
            }
        }
    }
    
    func delete(weather: WeatherData) -> Promise<Void> {
        localWeatherCache.delete(weather: weather)
    }
}
