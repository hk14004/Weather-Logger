//
//  DAO.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import UIKit
import CoreData

class EntityDAO<T: NSManagedObject> {
    
    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedController?.delegate = delegate
        }
    }
    
    private(set) var persistentConatiner: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    private(set) var fetchedController: NSFetchedResultsController<T>? {
        didSet {
             fetchedController?.delegate = delegate
        }
    }
    
    func save() throws {
        try persistentConatiner.viewContext.save()
    }
    
    func loadData(sectionNameKeyPath: String? = nil, cacheName: String? = nil, requestModifier: ((NSFetchRequest<T>) -> Void)? = nil ) throws -> [T] {
        // Default request
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: T.entity().name!)
        request.sortDescriptors = []
        
        // Modify request if necessary
        requestModifier?(request)
        
        // Perform fetch
        fetchedController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistentConatiner.viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        try fetchedController?.performFetch()
        
        return fetchedController?.fetchedObjects ?? []
    }
    
    func delete(at: IndexPath) throws {
        guard let toBeDeleted = fetchedController?.fetchedObjects?[at.row] else {
            return
        }
        persistentConatiner.viewContext.delete(toBeDeleted)
        try save()
    }
    
    func delete(_ toBeDeleted: [T]) throws {
        toBeDeleted.forEach {persistentConatiner.viewContext.delete($0)}
        try save()
    }
    
    func createEntity(entityModifier: (T) -> Void) throws {
        let new = T(context: persistentConatiner.viewContext)
        entityModifier(new)
        try save()
    }
}

