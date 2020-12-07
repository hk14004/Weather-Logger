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
        
    // TODO: Plug n play persistence
    private let weatherDao = EntityDAO<CityWeatherEntity>()
    
    private var loggingWeather: Bool = false {
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
    
    init(weatherProvider: WeatherProviderProtocol = WeatherService()) {
        self.weatherProvider = weatherProvider
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
    
    private func storeWeatherLog(from weatherData: CityWeatherData) {
        weatherDao.createEntity { (newEntity) in
            newEntity.city = weatherData.name
            newEntity.date = Date()
            newEntity.temp = weatherData.main.temp
            newEntity.feels_like = weatherData.main.feels_like
            newEntity.humidity = weatherData.main.humidity
            newEntity.pressure = weatherData.main.pressure
            newEntity.temp_max = weatherData.main.temp_max
            newEntity.temp_min = weatherData.main.temp_min
        }
    }
    
    func logCurrentWeather() {
        loggingWeather = true
        firstly {
            CLLocationManager.requestLocation().lastValue
        }.then { (location) in
            self.weatherProvider.getWeatherData(location: location)
        }.done  { (weatherData) in
            self.storeWeatherLog(from: weatherData)
        }.ensure {
            self.loggingWeather = false
        }
        .catch { (error) in
            print(error.localizedDescription)
            self.delegate?.onError(title: NSLocalizedString("Could not get current weather", comment: ""),
                                   message: NSLocalizedString("Please, try again later", comment: ""))
        }
    }
    
    func deleteWeatherData(at: IndexPath) {
        weatherDao.delete(at: at)
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
