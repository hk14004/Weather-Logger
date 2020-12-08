//
//  SavedWeatherVM.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import Foundation
import CoreData
import CoreLocation
import PromiseKit

class SavedWeatherVM: NSObject {
    
    weak var delegate: SavedWeatherVMDelegate?
    
    private let weatherProvider: WeatherProviderProtocol
        
    private let weatherDao = EntityDAO<CityWeatherEntity>()
    
    private let locationProvider: LocationProviderProtocol
    
    private(set) var loggingWeather: Bool = false {
        didSet {
            if (oldValue != loggingWeather) {
                delegate?.loggingStateChanged(loggingWeather)
            }
        }
    }
    
    private(set) var savedWeatherList: [CityWeatherEntity] = [] {
        didSet {
            if (oldValue.isEmpty != savedWeatherList.isEmpty) {
                delegate?.listVisibilityChanged(visible: !savedWeatherList.isEmpty)
            }
        }
    }
    
    init(weatherProvider: WeatherProviderProtocol = WeatherService(),
         locationProvider: LocationProviderProtocol = CLService()) {
        self.weatherProvider = weatherProvider
        self.locationProvider = locationProvider
        super.init()
        weatherDao.delegate = self
    }

    func loadData() {
        savedWeatherList = weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil, requestModifier: { (request) in
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        })
    }
    
    func getWeatherCellVM(at: IndexPath) -> SavedWeatherCellVM {
        return SavedWeatherCellVM(weatherModel: savedWeatherList[at.row])
    }
    
    private func storeWeatherLog(with weatherData: CityWeatherData) {
        weatherDao.createEntity { (newEntity) in
            newEntity.city = weatherData.cityWeatherDataResponse.name
            newEntity.date = Date()
            newEntity.temp = weatherData.cityWeatherDataResponse.main.temp
            newEntity.feels_like = weatherData.cityWeatherDataResponse.main.feels_like
            newEntity.humidity = weatherData.cityWeatherDataResponse.main.humidity
            newEntity.pressure = weatherData.cityWeatherDataResponse.main.pressure
            newEntity.temp_max = weatherData.cityWeatherDataResponse.main.temp_max
            newEntity.temp_min = weatherData.cityWeatherDataResponse.main.temp_min
            newEntity.forecast = weatherData.cityWeatherDataResponse.weather.first?.main
            newEntity.icon = weatherData.cityWeatherDataResponse.weather.first?.icon
            newEntity.forecastIconImg = weatherData.weatherIconImage.pngData()
        }
    }
    
    func logCurrentWeather() {
        loggingWeather = true
        
        firstly {
            locationProvider.getCurrentLocation()
        }.then { (location) in
            self.weatherProvider.getWeatherData(location: location)
        }.then { weatherDataResponse -> Promise<(CityWeatherDataResponse, UIImage)> in
            guard let iconName = weatherDataResponse.weather.first?.icon else  {
                throw NSError() // Throw a real error
            }
            return self.weatherProvider.getForecastIcon(with: iconName).map{(weatherDataResponse, $0)}
        }.done { (weatherDataResponse, weatherIcon) in
            let weatherData = CityWeatherData(cityWeatherDataResponse: weatherDataResponse, weatherIconImage: weatherIcon)
            self.storeWeatherLog(with: weatherData)
        }.ensure {
            self.loggingWeather = false
        }.catch { (error) in
            print(error.localizedDescription)
            self.delegate?.onError(title: NSLocalizedString("Could not get current weather", comment: ""),
                                   message: NSLocalizedString("Please, try again later", comment: ""))
        }
    }
    
    func deleteWeatherData(at: IndexPath) {
        weatherDao.delete(at: at)
    }
    
    func getWeatherEntity(at: IndexPath) -> CityWeatherEntity? {
        guard at.row < savedWeatherList.count else {
            return nil
        }
        
        return savedWeatherList[at.row]
    }
}

extension SavedWeatherVM: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.weatherListWillChange()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.weatherListChanged()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        savedWeatherList = (controller.fetchedObjects) as? [CityWeatherEntity] ?? []
        
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                delegate?.rowAdded(at: indexPath)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                delegate?.rowDeleted(at: indexPath)
            }
            break
        default:
            break
        }
    }
}

protocol SavedWeatherVMDelegate: class {
    func weatherListWillChange()
    func weatherListChanged()
    func rowAdded(at: IndexPath)
    func rowDeleted(at: IndexPath)
    func listVisibilityChanged(visible: Bool)
    func onError(title: String, message: String)
    func loggingStateChanged(_ isLogging: Bool)
}

struct CityWeatherData {
    
    let cityWeatherDataResponse: CityWeatherDataResponse
    
    let weatherIconImage: UIImage
    
    init(cityWeatherDataResponse: CityWeatherDataResponse,
         weatherIconImage: UIImage) {
        self.cityWeatherDataResponse = cityWeatherDataResponse
        self.weatherIconImage = weatherIconImage
    }
}


protocol LocationProviderProtocol {
    func getCurrentLocation() -> Promise<CLLocation>
}

class CLService: LocationProviderProtocol {
    func getCurrentLocation() -> Promise<CLLocation> {
        return CLLocationManager.requestLocation().lastValue
    }
}
