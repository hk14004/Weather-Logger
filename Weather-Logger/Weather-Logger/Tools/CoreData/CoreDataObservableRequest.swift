//
//  CoreDataObservableRequest.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import UIKit
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


// MARK: For CoreData - Refactor

extension WeatherData: Entity {
    public func toStorable(in context: NSManagedObjectContext) -> CityWeatherEntity {
        
        return CityWeatherEntity()
    }
}

public protocol Entity {
    associatedtype StoreType: Storable
    
    func toStorable(in context: NSManagedObjectContext) -> StoreType
}

public protocol Storable {
    associatedtype EntityObject: Entity
    
    var model: EntityObject { get }
}

