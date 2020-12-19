//
//  MainCoordinator.swift
//  Weather-Logger
//
//  Created by Hardijs on 18/12/2020.
//

import UIKit

class MainCoordinator: CoordinatorProtocol {
    var childCoordinators = [CoordinatorProtocol]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = SavedWeatherVC.instantiateWithMainStoryBoard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func show(weather: WeatherData) {
        let vc = WeatherDetailsVC.instantiateWithMainStoryBoard()
        vc.viewModel.prepare(for: weather)
        navigationController.pushViewController(vc, animated: true)
    }
}
