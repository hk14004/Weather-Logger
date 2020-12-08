//
//  CLService.swift
//  Weather-Logger
//
//  Created by Hardijs on 08/12/2020.
//

import Foundation
import PromiseKit

protocol LocationProviderProtocol {
    func getCurrentLocation() -> Promise<CLLocation>
}

class CLService: LocationProviderProtocol {
    func getCurrentLocation() -> Promise<CLLocation> {
        return CLLocationManager.requestLocation().lastValue
    }
}
