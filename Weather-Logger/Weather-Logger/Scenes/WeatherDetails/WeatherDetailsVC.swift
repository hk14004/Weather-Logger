//
//  WeatherDetailsVC.swift
//  Weather-Logger
//
//  Created by Hardijs on 07/12/2020.
//

import UIKit

class WeatherDetailsVC: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var forecastLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var forecastImageView: UIImageView!
    
    let viewModel = WeatherDetailsVM()
    
    override func viewDidLoad() {
        viewModel.delegate = self
        cityLabel.text = viewModel.city
        forecastLabel.text = viewModel.forecast
        temperatureLabel.text = viewModel.temperature
        forecastImageView.image = viewModel.icon
    }
}

extension WeatherDetailsVC: WeatherDetailsVMDelegate {
    func forecastImageLoaded(image: UIImage) {
        forecastImageView.image = image
    }
}
