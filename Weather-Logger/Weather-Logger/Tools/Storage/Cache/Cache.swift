//
//  Cache.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation

final class Cache<Key: Hashable, Value> {
    
    typealias ObserverClosure = ((Value, Key)->())
    var oninserted: ObserverClosure?
    var onUpdated: ObserverClosure?
    var onRemoved: ObserverClosure?
    var onCleared: (()->())?
    
    private(set) var itemList = Observable<[Value]>()

    private let wrapped = NSCache<WrappedKey, Entry>()
    private(set) var keys: Set<Key> = []

    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(with: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keys.insert(key)
        oninserted?(value,key)
        itemList.value = getAllValues()
    }

    func update(_ value: Value, forKey key: Key) {
        guard wrapped.object(forKey: WrappedKey(key)) != nil else {
            print("Trying to update item that no longer should exist: \(value)")
            return
        }

        let entry = Entry(with: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        onUpdated?(value,key)
        itemList.value = getAllValues()
    }

    func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }

    func removeValue(forKey key: Key) {
        guard let removed = wrapped.object(forKey: WrappedKey(key)) else {
            print("Trying to remove item that no longer should exist, key: \(key)")
            return
        }
        
        wrapped.removeObject(forKey: WrappedKey(key))
        keys.remove(key)
        onRemoved?(removed.value,key)
        itemList.value = getAllValues()
    }

    func clear() {
        wrapped.removeAllObjects()
        keys.removeAll()
        itemList.value = getAllValues()
    }
    
    private func getAllValues() -> [Value] {
        return keys.compactMap { value(forKey: $0) }
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension Cache {
    final class Entry {
        let value: Value

        init(with value: Value) {
            self.value = value
        }
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}
