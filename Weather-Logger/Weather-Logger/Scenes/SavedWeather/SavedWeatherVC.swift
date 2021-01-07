//
//  SavedWeatherVC.swift
//  Weather-Logger
//
//  Created by Hardijs on 03/12/2020.
//

import UIKit
import RxSwift
import RxCocoa

class SavedWeatherVC: UIViewController {
    
    // MARK: RX
    
    let disposeBag = DisposeBag()
    
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
    
    // MARK: Functions
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupTableView()
        setupLoadingView()
        observeViewModel()
        viewModel.loadAndObserveLogs()
    }
    
    // MARK: Actions
    
    @IBAction func logCurrentWeather(_ sender: UIBarButtonItem) {
        viewModel.onAddWeatherLog()
    }
    
    // MARK: Setup
    
    private func observeViewModel() {
        viewModel.weatherList.bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseIdentifier)) { row, _, cell in
            let cellVM = self.viewModel.getWeatherCellVM(at: IndexPath(row: row, section: 0))
            cell.setup(with: cellVM)
         }.disposed(by: disposeBag)
     
        viewModel.weatherList.map{$0.isEmpty}.distinctUntilChanged().subscribe { [weak self] isListEmpty in
            self?.changeUIState(emptyTable: isListEmpty)
        }.disposed(by: disposeBag)
        
        viewModel.isLogging.distinctUntilChanged().subscribe { [weak self] isLogging in
            self?.changeUIState(loading: isLogging)
        }.disposed(by: disposeBag)
        
        viewModel.errorTitleAndMessage.subscribe { [weak self] (title, message) in
            guard !title.isEmpty && !message.isEmpty else { return }
            self?.displayConfirmationAlert(title: title, message: message)
        }.disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    private func setupLoadingView() {
        view.addSubview(loadingSpinner)
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    // MARK: UI changes
    
    private func changeUIState(loading: Bool) {
        if loading {
            controls(enabled: false)
            loadingSpinner.startAnimating()
        } else {
            controls(enabled: true)
            loadingSpinner.stopAnimating()
        }
    }
    
    private func changeUIState(emptyTable: Bool) {
        if emptyTable {
            handleInvisibleTable()
        } else {
            handleVisibleTable()
        }
    }
    
    private func controls(enabled: Bool) {
        saveLogButton.isEnabled = enabled
    }
    
    private func handleInvisibleTable() {
        tableView.isHidden = true
        emptyTableLabel.isHidden = false
    }
    
    private func handleVisibleTable() {
        tableView.isHidden = false
        emptyTableLabel.isHidden = true
    }
    
    // MARK: Navigation
    
    private func showWeatherDetails(_ weather: WeatherData) {
        coordinator?.show(weather: weather)
    }
}

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
