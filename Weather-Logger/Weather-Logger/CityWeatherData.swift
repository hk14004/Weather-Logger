//
//  CityWeatherData.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import Foundation
import CoreLocation
import PromiseKit

struct CityWeatherData: Codable {
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
    let base: String
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Double
    let sys: Sys
    
    struct Sys: Codable {
        let type: Int
        let id: Int
        let country: String
        let sunrise: TimeInterval
        let sunset: TimeInterval
    }
    
    struct Clouds: Codable {
        let all: Double
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Double
    }
    
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Double
        let humidity: Double
    }
    
    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }
    
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
}


class WeatherService: WeatherProviderProtocol {
    
    let API_KEY = "511bd6233d15a788fa5d8d6ddd83b7c8"
    
    func getWeatherData(location: CLLocation) -> Promise<CityWeatherData> {
        let str = "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(API_KEY)&units=metric"
        
        print(str)
        let url = URL(string: str)!
        
        return firstly {
            URLSession.shared.dataTask(.promise, with: url)
        }.compactMap {
            try JSONDecoder().decode(CityWeatherData.self, from: $0.data)
        }
    }
}

protocol WeatherProviderProtocol {
    func getWeatherData(location: CLLocation) -> Promise<CityWeatherData>
}
