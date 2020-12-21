//
//  CoreDataWeatherCache.swift
//  Weather-Logger
//
//  Created by Hardijs on 20/12/2020.
//

import Foundation
import PromiseKit
import CoreData

class CoreDataObservableRequest<RepositoryObject>: ObservableFetchRequest<RepositoryObject>,
                                                   NSFetchedResultsControllerDelegate where RepositoryObject: Entity,
                                                                                            RepositoryObject.StoreType: NSManagedObject,
                                                                                            RepositoryObject.StoreType.EntityObject == RepositoryObject {
    
    private var fetchedResultsController: NSFetchedResultsController<RepositoryObject.StoreType>?
    
    override var value: [RepositoryObject]? {
        get {
            return fetchedResultsController?.fetchedObjects?.compactMap { $0.model }
        }
    }
    
    required init(with request: NSFetchRequest<RepositoryObject.StoreType>) throws {
        super.init()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self

        try fetchedResultsController?.performFetch()
    }
    
    override func observe(with owner: AnyObject, _ onChanged: @escaping ([RepositoryObject]?) -> (Void)) {
        observers.append(ObserverContainer(owner, onChanged))
        onChanged(value)
    }

    override func removeObserver(_ owner: AnyObject) {
        observers.removeAll { $0.owner === owner }
    }

    private func notifyObservers() {
        observers.removeAll { $0.owner == nil }
        observers.forEach { $0.onChanged(value) }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyObservers()
    }

}


protocol WeatherCacheProtocol {
    func getWeatherLogList() -> Promise<[WeatherData]>
    func getObservableWeatherLogList() -> Promise<ObservableFetchRequest<WeatherData>>
    func cache(weather: WeatherData) -> Promise<Void>
    func delete(weather: WeatherData) -> Promise<Void>
}

class CoreDataWeatherCache: WeatherCacheProtocol {
    
    func getObservableWeatherLogList() -> Promise<ObservableFetchRequest<WeatherData>> {
        Promise {
            let request: NSFetchRequest<CityWeatherEntity> = CityWeatherEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            let result = try CoreDataObservableRequest<WeatherData>(with: request)
            $0.fulfill(result)
        }
    }
    
    

    

    private let weatherDao = EntityDAO<CityWeatherEntity>()
    
    func getWeatherLogList() -> Promise<[WeatherData]> {
        Promise {
            let loadedWeather = try weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil, requestModifier: { (request) in
                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            })
            $0.fulfill(loadedWeather.compactMap { WeatherData(dataEntity: $0) })
        }
    }
    
    func cache(weather: WeatherData) -> Promise<Void> {
        Promise {
            try weatherDao.createEntity { (newEntity) in
                newEntity.setup(with: weather)
            }
            $0.fulfill(())
        }
    }
    
    func delete(weather: WeatherData) -> Promise<Void> {
        Promise {
            // TODO: Implement UUID
            let toBeDeleted = try weatherDao.loadData(sectionNameKeyPath: nil, cacheName: nil) { (reuqest) in
                reuqest.predicate = NSPredicate(format: "uuid == %@", weather.uuid as CVarArg )
            }
            try weatherDao.delete(toBeDeleted)
            $0.fulfill(())
        }
    }
}
