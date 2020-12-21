//
//  WeatherCacheProtocol.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation
import PromiseKit

// Repository uses this protocol to fetch local storage data

protocol WeatherCacheProtocol {
    func getWeatherList() -> Promise<ObservableFetchRequest<WeatherData>>
    func cache(weather: WeatherData) -> Promise<Void>
    func delete(weather: WeatherData) -> Promise<Void>
}
