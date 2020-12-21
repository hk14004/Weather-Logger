//
//  CoreDataObservableResult.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import UIKit
import CoreData

class CoreDataObservableResult<DomainType>: ObservableFetchResult<DomainType>,
                                            NSFetchedResultsControllerDelegate where DomainType: DomainModelProtocol,
                                                                                     DomainType.StoreType: NSManagedObject,
                                                                                     DomainType.StoreType.DomainModelType == DomainType {
    
    // MARK: Vars
    
    private var frc: NSFetchedResultsController<DomainType.StoreType>?
    
    override var value: [DomainType]? {
        get {
            return frc?.fetchedObjects?.compactMap { $0.toDomainModel() }
        }
    }
    
    // MARK: Init
    
    required init(with request: NSFetchRequest<DomainType.StoreType>) throws {
        super.init()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: context,
                                         sectionNameKeyPath: nil, cacheName: nil)
        frc?.delegate = self

        try frc?.performFetch()
    }
    
    // MARK: ObservableFetchResult
    
    override func observe(with owner: AnyObject, _ onChanged: @escaping ([DomainType]?) -> (Void)) {
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
