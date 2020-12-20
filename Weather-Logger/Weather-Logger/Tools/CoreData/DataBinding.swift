//
//  DataBinding.swift
//
//  Created by Hardijs on 15/08/2019.
//

import UIKit
import CoreData

class Observable<T> {
    var value: T? {
        didSet {
            notifyObservers()
        }
    }

    private var observers: [ObserverContainer<T>] = []

    init(_ v: T? = nil) {
        value = v
    }

    func observe(with owner: AnyObject, _ onChanged: @escaping (T?) -> (Void)) {
        observers.append(ObserverContainer(owner, onChanged))
        onChanged(value)
    }

    func removeObserver(_ owner: AnyObject) {
        observers.removeAll { $0.owner === owner }
    }

    func notifyObservers() {
        observers.removeAll { $0.owner == nil }
        observers.forEach { $0.onChanged(value) }
    }
}

class ObserverContainer<T> {
    weak var owner: AnyObject?
    var onChanged: (T?) -> (Void)

    init(_ owner: AnyObject, _ onChanged: @escaping (T?) -> (Void)) {
        self.owner = owner
        self.onChanged = onChanged
    }
}

class ObservableFetchRequestResult<T>: NSObject, NSFetchedResultsControllerDelegate where T: NSFetchRequestResult {
    private(set) var observers: [ObserverContainer<[T]>] = []
    private var fetchedResultsController: NSFetchedResultsController<T>?
    var value: [T]? {
        get {
            return fetchedResultsController?.fetchedObjects
        }
    }

    override private init() {}

    init(with request: NSFetchRequest<T>) {
        super.init()

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Unhandled error: ", error)
        }
    }

    func observe(with owner: AnyObject, _ onChanged: @escaping ([T]?) -> (Void)) {
        observers.append(ObserverContainer(owner, onChanged))
        onChanged(value)
    }

    func removeObserver(_ owner: AnyObject) {
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


//protocol ObservableFetchRequestProtocol {
//    associatedtype T
//    var observers: [ObserverContainer<[T]>] { get }
//    var value: [T]? { get }
//    func observe(with owner: AnyObject, _ onChanged: @escaping ([T]) -> (Void))
//    func removeObserver(_ owner: AnyObject)
//}


class ObservableFetchRequest<T>: NSObject {
    var observers: [ObserverContainer<[T]>] = []
    
    private(set) var value: [T]? = []
    
    func observe(with owner: AnyObject, _ onChanged: @escaping ([T]?) -> (Void)) {
        
    }
    
    func removeObserver(_ owner: AnyObject) {
        
    }
}
