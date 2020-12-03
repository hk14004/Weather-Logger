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
    }
    
    @IBAction func onSavePressed(_ sender: UIButton) {
        savedWeatherVM.saveCurrentWeather()
    }
    
}

extension SavedWeatherVC: UITableViewDelegate {
    
}

extension SavedWeatherVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
