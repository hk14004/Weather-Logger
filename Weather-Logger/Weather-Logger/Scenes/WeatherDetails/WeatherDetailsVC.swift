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
    
    private(set) var weatherDetailsVM = WeatherDetailsVM()
    
    override func viewDidLoad() {
        weatherDetailsVM.delegate = self
        cityLabel.text = weatherDetailsVM.city
        forecastLabel.text = weatherDetailsVM.forecast
        temperatureLabel.text = weatherDetailsVM.temperature
        forecastImageView.image = weatherDetailsVM.icon
    }
}

extension WeatherDetailsVC: WeatherDetailsVMDelegate {
    func forecastImageLoaded(image: UIImage) {
        forecastImageView.image = image
    }
}
