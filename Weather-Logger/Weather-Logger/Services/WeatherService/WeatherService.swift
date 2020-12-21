//
//  WeatherService.swift
//  Weather-Logger
//
//  Created by Hardijs on 08/12/2020.
//

import Foundation
import PromiseKit

protocol RemoteWeatherProviderProtocol {
    func getWeatherData(location: CLLocation) -> Promise<CityWeatherDataResponse>
    func getForecastIcon(with name: String) -> Promise<UIImage>
}

class WeatherService: RemoteWeatherProviderProtocol {
    
    let API_KEY = "511bd6233d15a788fa5d8d6ddd83b7c8"
    
    func getWeatherData(location: CLLocation) -> Promise<CityWeatherDataResponse> {
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(API_KEY)&units=metric")!
        
        return URLSession.shared.dataTask(.promise, with: url).compactMap {
            try JSONDecoder().decode(CityWeatherDataResponse.self, from: $0.data)
        }
    }
    
    func getForecastIcon(with name: String) -> Promise<UIImage> {
        let url = URL(string: "http://openweathermap.org/img/wn/\(name)@2x.png")!
        
        return URLSession.shared.dataTask(.promise, with: url).compactMap { UIImage(data: $0.data) }
    }
}
