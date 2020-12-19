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

class SavedWeatherVM {
    
    weak var delegate: SavedWeatherVMDelegate?
    
    private let locationProvider: LocationProviderProtocol
    
    private let weatherRepository: WeatherRepositoryProtocol
    
    private(set) var loggingWeather: Bool = false {
        didSet {
            if (oldValue != loggingWeather) {
                delegate?.loggingStateChanged(loggingWeather)
            }
        }
    }
    
    private(set) var loadedWeatherLogs: [WeatherData] = [] {
        didSet {
            if (oldValue.isEmpty != loadedWeatherLogs.isEmpty) {
                delegate?.listVisibilityChanged(visible: !loadedWeatherLogs.isEmpty)
            }
            
        }
    }
    
    init(locationProvider: LocationProviderProtocol = CLService(),
         weatherRepository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.locationProvider = locationProvider
        self.weatherRepository = weatherRepository
    }

    func loadData() {
        weatherRepository.getWeatherLogList().done { (logs) in
            self.loadedWeatherLogs = logs
            self.delegate?.reloadWeatherLogTable()
        }.catch { (error) in
            print("Could not load from persistent store: \(error)")
        }
    }
    
    func getWeatherCellVM(at: IndexPath) -> SavedWeatherCellVM {
        return SavedWeatherCellVM(weatherModel: loadedWeatherLogs[at.row])
    }
    
    func deleteWeatherData(at: IndexPath) {
        //weatherDao.delete(at: at)
    }
    
    func getWeatherEntity(at: IndexPath) -> CityWeatherEntity? {
        return nil
//        guard at.row < loadedWeatherLogs.count else {
//            return nil
//        }
//
//        return loadedWeatherLogs[at.row]
    }
    
    func addWeatherLog() {
        loggingWeather = true
        
        firstly {
            locationProvider.getCurrentLocation()
        }.then { (location) in
            self.weatherRepository.createWeatherLog(for: location)
        }.done { (log) in
            print("New log added", log)
        }.ensure {
            self.loggingWeather = false
        }.catch { (error) in
            print("Error")
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
    func reloadWeatherLogTable()
}


// CREATE NEW: return promise of new entry, append at the end.
// DELETE: by some id only, delete from mvvm and storage
