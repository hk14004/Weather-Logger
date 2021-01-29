//
//  DataSource.swift
//  Weather-Logger
//
//  Created by Hardijs on 29/01/2021.
//

import UIKit

class WeatherDataSource<T: Hashable,U: Hashable>: UITableViewDiffableDataSource<T, U> {

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}
