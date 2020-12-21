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

class ObservableFetchResult<T>: NSObject {
    var observers: [ObserverContainer<[T]>] = []
    
    private(set) var value: [T]? = []
    
    func observe(with owner: AnyObject, _ onChanged: @escaping ([T]?) -> (Void)) {}
    
    func removeObserver(_ owner: AnyObject) {}
}
