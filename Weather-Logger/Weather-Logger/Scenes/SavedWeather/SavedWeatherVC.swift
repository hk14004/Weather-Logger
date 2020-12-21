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
    
    private let viewModel = SavedWeatherVM()
    
    private lazy var source = DataSource<Int, WeatherData>(tableView: self.tableView) { (tableView,indexPath, item) -> UITableViewCell? in
        let cell: UITableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellVM = self.viewModel.getWeatherCellVM(at: indexPath)
        cell.setup(with: cellVM)

        return cell
    }
    
    // MARK: Functions
    
    override func viewDidLoad() {
        setupTableView()
        setupLoadingView()
        viewModel.delegate = self
        viewModel.loadAndObserveLogs()
    }
    
    private func setupTableView() {
        tableView.delegate = self
//        tableView.dataSource = self
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
        viewModel.onAddWeatherLog()
    }
    
    private func controls(enabled: Bool) {
        saveLogButton.isEnabled = enabled
    }
    
    private func setupLoadingView() {
        if viewModel.loggingWeather {
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
    
    private func showWeatherDetails(_ weather: WeatherData) {
        coordinator?.show(weather: weather)
    }
}

extension SavedWeatherVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, completionHandler) in
//            guard let item = self.source.itemIdentifier(for: indexPath) else { return }
////            self.container.viewContext.delete(item)
////            self.updateSnapshot()
//            completionHandler(true)
//        }
//        deleteAction.image = UIImage(systemName: "trash.fill")
//
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let weatherData = viewModel.getWeather(at: indexPath)
        showWeatherDetails(weatherData)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: NSLocalizedString("Delete", comment: "")) {[unowned self] _, _, complete in
            viewModel.onDeleteWeather(at: indexPath)
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
        return viewModel.loadedWeatherLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellVM = viewModel.getWeatherCellVM(at: indexPath)
        cell.setup(with: cellVM)

        return cell
    }
}

extension SavedWeatherVC: SavedWeatherVMDelegate {
    func reloadWeatherLogTable() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, WeatherData>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.loadedWeatherLogs)
        source.apply(snapshot, animatingDifferences: source.snapshot().numberOfItems == 0 ? false : true)
    }
    
    func loggingStateChanged(_ isLogging: Bool) {
        changeState(loading: isLogging)
    }
    
    func onError(title: String, message: String) {
        displayConfirmationAlert(title: title, message: message)
    }
    
    func rowAdded(at: IndexPath) {
        tableView.insertRows(at: [at], with: .automatic)
    }
    
    func rowDeleted(at: IndexPath) {
        tableView.deleteRows(at: [at], with: .left)
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

class DataSource<T: Hashable,U: Hashable>: UITableViewDiffableDataSource<T, U> {
    // ...
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // ...
}
