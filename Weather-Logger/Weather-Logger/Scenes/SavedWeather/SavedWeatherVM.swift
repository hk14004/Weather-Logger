//
//  SavedWeatherVM.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import Foundation
import CoreData

class SavedWeatherVM: NSObject {
    
    weak var delegate: SavedWeatherVMDelegate?
    
    private let weatherAPI: WeatherAPIProtocol
    
    private let weatherDao = EntityDAO<CityWeatherEntity>()
    
    private(set) var savedWeatherList: [CityWeatherEntity] = []
    
    var locManager = CLLocationManager()
    
    init(weatherAPI: WeatherAPIProtocol = WeatherAPI()) {
        self.weatherAPI = weatherAPI
        super.init()
        weatherDao.delegate = self
        savedWeatherList = weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil, requestModifier: { (request) in
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        })
        locManager.requestWhenInUseAuthorization()
    }
    
    func getWeatherCellVM(at: IndexPath) -> SavedWeatherCellVM {
        SavedWeatherCellVM(weatherModel: savedWeatherList[at.row])
    }
    
    func saveCurrentWeather() {
        guard let location = getCurrentLocation() else {
            return
        }
        
        getPlace(for: location) { placemark in
            guard
                let placemark = placemark,
                let city = placemark.locality else {
                return
            }
            
            self.weatherAPI.getWeatherData(city: city) { [weak self] (data) in
                
                guard let weatherData = data else {
                    // TODO: Show error
                    return
                }
                
                self?.weatherDao.createEntity { (newEntity) in
                    newEntity.city = city
                    newEntity.date = Date()
                    newEntity.temp = weatherData.main.temp
                    newEntity.feels_like = weatherData.main.feels_like
                    newEntity.humidity = weatherData.main.humidity
                    newEntity.pressure = weatherData.main.pressure
                    newEntity.temp_max = weatherData.main.temp_max
                    newEntity.temp_min = weatherData.main.temp_min
                }
                
                self?.weatherDao.save()
            }
            
        }


    }
    
    func deleteWeatherData(at: IndexPath) {
        weatherDao.delete(at: at)
        weatherDao.save()
    }
    
    func getCurrentLocation() -> CLLocation? {
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = locManager.location else {
                return nil
            }
            return currentLocation
        }
        
        return nil
    }
    
    func getPlace(for location: CLLocation,
                  completion: @escaping (CLPlacemark?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
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
        case .update:
            if let indexPath = indexPath {
                delegate?.rowUpdated(at: indexPath)
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
    func rowUpdated(at: IndexPath)
}
