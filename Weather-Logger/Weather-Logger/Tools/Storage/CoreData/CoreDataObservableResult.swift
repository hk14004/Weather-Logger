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
                                                                                     DomainType.CoreDataStoreType: NSManagedObject,
                                                                                     DomainType.CoreDataStoreType.DomainModelType == DomainType {
    
    // MARK: Vars
    
    private var frc: NSFetchedResultsController<DomainType.CoreDataStoreType>?
    
    override var value: [DomainType]? {
        get {
            return frc?.fetchedObjects?.compactMap { $0.toDomainModel() }
        }
    }
    
    // MARK: Init
    
    required init(with request: NSFetchRequest<DomainType.CoreDataStoreType>) throws {
        super.init()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: context,
                                         sectionNameKeyPath: nil, cacheName: nil)
        frc?.delegate = self

        try frc?.performFetch()
    }
    
    // MARK: Functions

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyObservers()
    }
}
