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
        weatherRepository.delete(weatherLog: loadedWeatherLogs[at.row]).done {
            self.deleteLogFromTable(at: at)
        }.catch { (error) in
            self.delegate?.onError(title: NSLocalizedString("Error", comment: ""),
                                   message: NSLocalizedString("Could not delete weather log", comment: ""))
        }
    }
        
    private func deleteLogFromTable(at: IndexPath) {
        delegate?.weatherListWillChange()
        loadedWeatherLogs.remove(at: at.row)
        delegate?.rowDeleted(at: at)
        delegate?.weatherListChanged()
    }
    
    private func insertLogIntoTable(log: WeatherData) {
        delegate?.weatherListWillChange()
        loadedWeatherLogs.append(log)
        delegate?.rowAdded(at: IndexPath(row: loadedWeatherLogs.count - 1, section: 0))
        delegate?.weatherListChanged()
    }
    
    func onAddWeatherLog() {
        loggingWeather = true
        
        firstly {
            locationProvider.getCurrentLocation()
        }.then(on: DispatchQueue.global(qos: .userInteractive)) { (location) in
            self.weatherRepository.createWeatherLog(for: location)
        }.done { (log) in
            self.insertLogIntoTable(log: log)
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
