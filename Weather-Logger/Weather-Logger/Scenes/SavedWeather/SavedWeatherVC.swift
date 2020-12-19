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
    
    @IBOutlet weak var saveLogButton: UIBarButtonItem!
    
    @IBOutlet weak var emptyTableLabel: UILabel!
    
    // MARK: Vars
    
    weak var coordinator: MainCoordinator?
    
    private lazy var loadingSpinner: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .large)
    }()
    
    private let savedWeatherVM = SavedWeatherVM()
    
    // MARK: Functions
    
    override func viewDidLoad() {
        setupTableView()
        setupLoadingView()
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
        savedWeatherVM.addWeatherLog()
    }
    
    private func controls(enabled: Bool) {
        saveLogButton.isEnabled = enabled
    }
    
    private func setupLoadingView() {
        if savedWeatherVM.loggingWeather {
            loadingSpinner.startAnimating()
            loadingSpinner.isHidden = false
        }
        view.addSubview(loadingSpinner)
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func changeState(loading: Bool) {
        if loading {
            controls(enabled: false)
            loadingSpinner.isHidden = false
            loadingSpinner.startAnimating()
        } else {
            controls(enabled: true)
            loadingSpinner.isHidden = true
            loadingSpinner.stopAnimating()
        }
    }
    
    private func showWeatherDetails(_ weather: CityWeatherEntity) {
        coordinator?.show(weather: weather)
    }
}

extension SavedWeatherVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: NSLocalizedString("Delete", comment: "")) {[unowned self] _, _, complete in
            savedWeatherVM.deleteWeatherData(at: indexPath)
            complete(true)
        }

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
        return savedWeatherVM.loadedWeatherLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellVM = savedWeatherVM.getWeatherCellVM(at: indexPath)
        cell.setup(with: cellVM)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let weatherData = savedWeatherVM.getWeatherEntity(at: indexPath) else { return }
        showWeatherDetails(weatherData)
    }
}

extension SavedWeatherVC: SavedWeatherVMDelegate {
    
    func reloadWeatherLogTable() {
        tableView.reloadData()
    }
    
    func loggingStateChanged(_ isLogging: Bool) {
        changeState(loading: isLogging)
    }
    
    func onError(title: String, message: String) {
        displayConfirmationAlert(title: title, message: message)
    }
    
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
