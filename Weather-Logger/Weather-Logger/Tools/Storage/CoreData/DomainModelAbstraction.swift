//
//  DomainModelAbstraction.swift.swift
//  Weather-Logger
//
//  Created by Hardijs on 21/12/2020.
//

import Foundation

// All domain models should implement this protocol

protocol DomainModelProtocol {
    associatedtype CoreDataStoreType: DomainModelHolderProtocol
    associatedtype RealmStoreType: DomainModelHolderProtocol
}

// All persistent entities should implement this protocol

protocol DomainModelHolderProtocol {
    associatedtype DomainModelType: DomainModelProtocol
    
    func toDomainModel() -> DomainModelType?
}
