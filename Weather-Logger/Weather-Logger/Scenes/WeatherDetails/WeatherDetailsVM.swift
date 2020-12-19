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
    
    private(set) var city: String?
    
    private(set) var forecast: String?
    
    private(set) var temperature: String?
    
    private(set) var icon: UIImage? {
        didSet {
            if let icon = icon {
                delegate?.forecastImageLoaded(image: icon)
            }
        }
    }
    
    private let weatherProvider: WeatherProviderProtocol
    
    private let weatherDao = EntityDAO<CityWeatherEntity>()
    
    func setup(weather: CityWeatherEntity) {
        city = weather.city
        temperature = "\(Measurement(value: weather.temp, unit: UnitTemperature.celsius))"
        forecast = weather.forecast
        if let storedIconImageData = weather.forecastIconImg {
            self.icon = UIImage(data: storedIconImageData)
        }
        
        updateWeatherResources(weather: weather)
    }
    
    private func updateWeatherResources(weather: CityWeatherEntity) {
        guard let iconName = weather.icon else {
            return
        }
        
        firstly {
            weatherProvider.getForecastIcon(with: iconName)
        }.done { (image) in
            // Avoiding single source of truth, but as of now there is no way how entity would be changed behind our backs
            let newIconData = image.pngData()
            if weather.forecastIconImg != newIconData {
                self.icon = image
                weather.forecastIconImg = newIconData
                try self.weatherDao.save()
            }
        }.catch { (error) in
            print(error.localizedDescription)
        }
    }
    
    init(weatherProvider: WeatherProviderProtocol = WeatherService()) {
        self.weatherProvider = weatherProvider
    }
}

protocol WeatherDetailsVMDelegate: class  {
    func forecastImageLoaded(image: UIImage)
}
