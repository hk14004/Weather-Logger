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
    
    @IBOutlet weak var emptyTableLabel: UILabel!
    
    // MARK: Vars
    
    private let savedWeatherVM = SavedWeatherVM()
    
    // MARK: Functions
    
    override func viewDidLoad() {
        setupTableView()
        savedWeatherVM.delegate = self
        savedWeatherVM.loadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func handleInvisibleTable() {
        tableView.isHidden = true
        emptyTableLabel.isHidden = false
    }
    
    private func handleVisibleTable() {
        tableView.isHidden = false
        emptyTableLabel.isHidden = true
    }
    
    @IBAction func logCurrentWeather(_ sender: UIBarButtonItem) {
        savedWeatherVM.logCurrentWeather()
    }
}

extension SavedWeatherVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: NSLocalizedString("Delete", comment: "")) {[unowned self] _, _, complete in
            savedWeatherVM.deleteWeatherData(at: indexPath)
            complete(true)
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}

extension SavedWeatherVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedWeatherVM.savedWeatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "\(UITableViewCell.self)"
        var cell: UITableViewCell
        
        if let dequeuedcell = tableView.dequeueReusableCell(withIdentifier: cellId) {
            cell = dequeuedcell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        }
        
        let cellVM = savedWeatherVM.getWeatherCellVM(at: indexPath)
        cell.setup(with: cellVM)

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
    
    func weatherListWillChange() {
        tableView.beginUpdates()
    }
    
    func weatherListChanged() {
        tableView.endUpdates()
    }
    
    func listVisibilityChanged(visible: Bool) {
        if visible {
            handleVisibleTable()
        } else {
            handleInvisibleTable()
        }
    }
}
