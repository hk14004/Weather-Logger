//
//  NSCacheObservableResult.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation

class NSCacheObservableResult<Key:Hashable, T>: ObservableFetchResult<T> {
    
    typealias CacheType = Cache<Key,T>

    private let cache: CacheType

    override var value: [T]? {
        get {
            return setValue
        }
    }
    
    private var setValue: [T]? {
        didSet {
            notifyObservers()
        }
    }
    
    init(with cache: CacheType, sortedBy: @escaping ((T,T) throws ->Bool)) {
        self.cache = cache
        super.init()
        
        cache.itemList.observe(with: self) { [weak self] items in
            self?.setValue = try? items?.sorted(by: sortedBy) ?? []
        }
    }
}
