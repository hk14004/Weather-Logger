//
//  SavedWeatherVM.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import Foundation
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
    
    private var loadRequest: ObservableFetchRequest<WeatherData>?
    
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
    
    func loadAndObserveLogs() {
        weatherRepository.getWeatherList().done { (observableRequest) in
            self.loadRequest = observableRequest
            observableRequest.observe(with: self) { logs in
                self.loadedWeatherLogs = logs ?? []
                self.delegate?.reloadWeatherLogTable()
            }
        }.catch { (error) in
            self.delegate?.onError(title: NSLocalizedString("Error", comment: ""),
                                   message: NSLocalizedString("Could not load weather logs", comment: ""))
        }
    }
    
    func getWeather(at: IndexPath) -> WeatherData {
        return loadedWeatherLogs[at.row]
    }
    
    func getWeatherCellVM(at: IndexPath) -> SavedWeatherCellVM {
        return SavedWeatherCellVM(weatherModel: loadedWeatherLogs[at.row])
    }
    
    func onDeleteWeather(at: IndexPath) {
        weatherRepository.delete(weather: loadedWeatherLogs[at.row]).catch { (error) in
            self.delegate?.onError(title: NSLocalizedString("Error", comment: ""),
                                   message: NSLocalizedString("Could not delete weather log", comment: ""))
        }
    }
        
    func onAddWeatherLog() {
        loggingWeather = true
        
        firstly {
            locationProvider.getCurrentLocation()
        }.then(on: DispatchQueue.global(qos: .userInteractive)) { (location) in
            self.weatherRepository.insertWeatherLog(for: location)
        }.ensure {
            self.loggingWeather = false
        }.catch { (error) in
            self.delegate?.onError(title: NSLocalizedString("Error", comment: ""),
                                   message: NSLocalizedString("Could not add weather log", comment: ""))
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
