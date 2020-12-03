//
//  SavedWeatherVC.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import UIKit

class SavedWeatherVC: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: Vars
    
    private let savedWeatherVM = SavedWeatherVM()
    
    // MARK: Functions
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        savedWeatherVM.delegate = self
    }
    
    @IBAction func onSavePressed(_ sender: UIButton) {
        savedWeatherVM.saveCurrentWeather()
    }
    
}

extension SavedWeatherVC: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, complete in
            self.savedWeatherVM.deleteWeatherData(at: indexPath)
            complete(true)
        }
        
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
}

extension SavedWeatherVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedWeatherVM.savedWeatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell")!
        let cellVM = savedWeatherVM.getWeatherCellVM(at: indexPath)
        cell.textLabel?.text = cellVM.cellTitle
        cell.detailTextLabel?.text = cellVM.dateString
        
        return cell
        
    }
}

extension SavedWeatherVC: SavedWeatherVMDelegate {
    func rowAdded(at: IndexPath) {
        tableView.insertRows(at: [at], with: .fade)
    }
    
    func rowDeleted(at: IndexPath) {
        tableView.deleteRows(at: [at], with: .fade)
    }
    
    func rowUpdated(at: IndexPath) {}
    
    func weatherListWillChange() {
        tableView.beginUpdates()
    }
    
    func weatherListChanged() {
        tableView.endUpdates()
    }
}
