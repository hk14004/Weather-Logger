//
//  CoreDataObservableResult.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import UIKit
import CoreData

class CoreDataObservableResult<DomainObject>: ObservableFetchResult<DomainObject>,
                                              NSFetchedResultsControllerDelegate where DomainObject: DomainModelProtocol,
                                                                                       DomainObject.StoreType: NSManagedObject,
                                                                                       DomainObject.StoreType.DomainType == DomainObject {
    
    // MARK: Vars
    
    private var frc: NSFetchedResultsController<DomainObject.StoreType>?
    
    override var value: [DomainObject]? {
        get {
            return frc?.fetchedObjects?.compactMap { $0.toDomainModel() }
        }
    }
    
    // MARK: Init
    
    required init(with request: NSFetchRequest<DomainObject.StoreType>) throws {
        super.init()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: context,
                                         sectionNameKeyPath: nil, cacheName: nil)
        frc?.delegate = self

        try frc?.performFetch()
    }
    
    // MARK: ObservableFetchResult functions
    
    override func observe(with owner: AnyObject, _ onChanged: @escaping ([DomainObject]?) -> (Void)) {
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


// MARK: For CoreData - Refactor

extension WeatherData: DomainModelProtocol {
    public func toStorable(in context: NSManagedObjectContext) -> CityWeatherEntity {
        
        return CityWeatherEntity()
    }
}

public protocol DomainModelProtocol {
    associatedtype StoreType: DomainHolderProtocol
    
    func toStorable(in context: NSManagedObjectContext) -> StoreType
}

public protocol DomainHolderProtocol {
    associatedtype DomainType: DomainModelProtocol
    
    func toDomainModel() -> DomainType
}

