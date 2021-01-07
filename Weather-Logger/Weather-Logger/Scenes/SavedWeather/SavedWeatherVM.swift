//
//  SavedWeatherVM.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import Foundation
import PromiseKit
import RxSwift
import RxCocoa

class SavedWeatherVM {
    
    // MARK: RX
    
    let weatherList: BehaviorRelay<[WeatherData]> = BehaviorRelay(value: [])
    
    let isLogging: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    let errorTitleAndMessage: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("", ""))
    
    // MARK: Non RX
    
    private let locationProvider: LocationProviderProtocol
    
    private let weatherRepository: WeatherRepositoryProtocol
    
    private var loadRequest: ObservableFetchResult<WeatherData>? {
        didSet {
            oldValue?.removeObserver(self)
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
            observableRequest.observe(with: self) { [weak self] logs in
                self?.weatherList.accept(logs ?? [])
            }
        }.catch { (error) in
            self.errorTitleAndMessage.accept((NSLocalizedString("Error", comment: ""),
                                   message: NSLocalizedString("Could not load weather logs", comment: "")))
        }
    }
    
    func getWeather(at: IndexPath) -> WeatherData {
        return weatherList.value[at.row]
    }
    
    func getWeatherCellVM(at: IndexPath) -> SavedWeatherCellVM {
        return SavedWeatherCellVM(weatherModel: weatherList.value[at.row])
    }
    
    func onDeleteWeather(at: IndexPath) {
        weatherRepository.delete(weather: weatherList.value[at.row]).catch { (error) in
            self.errorTitleAndMessage.accept((NSLocalizedString("Error", comment: ""),
                                   message: NSLocalizedString("Could not delete weather log", comment: "")))
        }
    }
        
    func onAddWeatherLog() {
        isLogging.accept(true)
        
        firstly {
            locationProvider.getCurrentLocation()
        }.then(on: DispatchQueue.global(qos: .userInteractive)) { (location) in
            self.weatherRepository.insertWeatherLog(for: location)
        }.ensure {
            self.isLogging.accept(false)
        }.catch { (error) in
            self.errorTitleAndMessage.accept((NSLocalizedString("Error", comment: ""),
                                              NSLocalizedString("Could not add weather log", comment: "")))
        }
    }
}
