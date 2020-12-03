//
//  CityWeatherData.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import Foundation

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


class WeatherAPI: WeatherAPIProtocol {
    func getWeatherData(city: String = "Riga", completion: @escaping (CityWeatherData?) -> Void) {
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=511bd6233d15a788fa5d8d6ddd83b7c8")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in

            if error != nil || data == nil {
                print("Client error!")
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }

            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }

            let dataDecoded = try? JSONDecoder().decode(CityWeatherData?.self, from: data!)
            completion(dataDecoded)
            
        }

        task.resume()
    }
}

protocol WeatherAPIProtocol {
    func getWeatherData(city: String, completion: @escaping (CityWeatherData?) -> Void)
}
