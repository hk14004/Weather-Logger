//
//  RealmObservableResult.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation
import RealmSwift

class RealmObservableResult<DomainType>: ObservableFetchResult<DomainType> where DomainType: DomainModelProtocol,
                                                                                 DomainType.RealmStoreType: RealmCollectionValue,
                                                                                 DomainType.RealmStoreType.DomainModelType == DomainType {
    
    var realmResult: Results<DomainType.RealmStoreType>
    
    var subscriptionToken: NotificationToken?
    
    override var value: [DomainType]? {
        get {
            return realmResult.compactMap { $0.toDomainModel() }
        }
    }
    
    required init(realmResult: Results<DomainType.RealmStoreType>) {
        self.realmResult = realmResult
        self.subscriptionToken = nil
        super.init()
        subscriptionToken = realmResult.observe { [weak self] _ in
            self?.notifyObservers()
        }
    }
}
