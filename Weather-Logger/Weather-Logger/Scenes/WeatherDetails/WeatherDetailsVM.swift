//
//  WeatherDetailsVM.swift
//  Weather-Logger
//
//  Created by Hardijs on 07/12/2020.
//

import UIKit
import PromiseKit

class WeatherDetailsVM {
    
    weak var delegate: WeatherDetailsVMDelegate?
    
    private(set) var city: String = ""
    
    private(set) var forecast: String = ""
    
    private(set) var temperature: String = ""
    
    private(set) var icon: UIImage = UIImage() {
        didSet {
            delegate?.forecastImageLoaded(image: icon)
        }
    }
        
    private let weatherProvider: WeatherProviderProtocol
    
    private let weatherDao = EntityDAO<CityWeatherEntity>()

    init(weatherProvider: WeatherProviderProtocol = WeatherService()) {
        self.weatherProvider = weatherProvider
    }
    
    func prepare(for weather: WeatherData) {
        city = weather.city
        temperature = "\(Measurement(value: weather.temp, unit: UnitTemperature.celsius))"
        forecast = weather.forecast
        icon = weather.iconImage
        
        // TODO: Update weather resources?
    }
}

protocol WeatherDetailsVMDelegate: class  {
    func forecastImageLoaded(image: UIImage)
}
