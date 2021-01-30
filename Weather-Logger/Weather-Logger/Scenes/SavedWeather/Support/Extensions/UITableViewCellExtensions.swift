//
//  UITableViewCellExtensions.swift
//  Weather-Logger
//
//  Created by Hardijs on 04/12/2020.
//

import UIKit

class SavedWeatherCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var forecastImageView: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    
    func setup(with viewModel: SavedWeatherCellVM) {
        if let forcastImageData = viewModel.forecastImageData {
            forecastImageView.image = UIImage(data: forcastImageData)
            //forecastImageView.backgroundColor = .red
        }
        
        title.text = viewModel.title
        subtitle.text = viewModel.subtitle
        temperature.text = viewModel.temperature
    }
}
