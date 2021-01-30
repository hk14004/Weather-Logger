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
    
    private lazy var source = WeatherDataSource<Int, WeatherData>(tableView: tableView) { (tableView,indexPath, item) -> UITableViewCell? in
        let cell: SavedWeatherCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellVM = self.viewModel.getWeatherCellVM(at: indexPath)
        cell.setup(with: cellVM)

        return cell
    }
    
    // MARK: Functions
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupTableView()
        setupLoadingView()
        viewModel.delegate = self
        viewModel.loadAndObserveLogs()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        changeState(tableIsHidden: viewModel.tableIsHidden)
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    private func changeState(tableIsHidden: Bool) {
        tableView.isHidden = tableIsHidden
        emptyTableLabel.isHidden = !tableIsHidden
    }
    
    @IBAction func logCurrentWeather(_ sender: UIBarButtonItem) {
        viewModel.onAddWeatherLog()
    }
    
    private func controls(enabled: Bool) {
        saveLogButton.isEnabled = enabled
    }
    
    private func setupLoadingView() {
        // Setup
        if viewModel.loggingWeather {
            loadingSpinner.startAnimating()
        }
        
        loadingSpinner.hidesWhenStopped = true
        
        // Hierarchy
        view.addSubview(loadingSpinner)
        
        // Layout
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func changeState(loading: Bool) {
        controls(enabled: !loading)
        loadingSpinner.isHidden = !loading
        
        if loading {
            loadingSpinner.startAnimating()
        } else {
            loadingSpinner.stopAnimating()
        }
    }
    
    private func showWeatherDetails(_ weather: WeatherData) {
        coordinator?.show(weather: weather)
    }
}

// MARK: UITableViewDelegate

extension SavedWeatherVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
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

// MARK: SavedWeatherVMDelegate

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
    
    func tableStateChanged(isHidden: Bool) {
        changeState(tableIsHidden: isHidden)
    }
}
