//
//  UIViewControllerExtensions.swift
//  Sensors
//
//  Created by Hardijs on 02/12/2020.
//

import UIKit

extension UIViewController {
    func displayConfirmationAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
