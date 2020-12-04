//
//  UITableViewCellExtensions.swift
//  Weather-Logger
//
//  Created by Hardijs on 04/12/2020.
//

import UIKit

extension UITableViewCell {
    func setup(with viewModel: SavedWeatherCellVM) {
        textLabel?.text = viewModel.cellTitle
        detailTextLabel?.text = viewModel.dateString
        accessoryType = .disclosureIndicator
    }
}
