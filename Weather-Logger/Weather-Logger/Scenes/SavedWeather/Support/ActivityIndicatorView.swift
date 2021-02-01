//
//  ActivityIndicatorView.swift
//  Weather-Logger
//
//  Created by Hardijs on 01/02/2021.
//

import UIKit

class LoadingView: UIActivityIndicatorView {
    
    override init(style: UIActivityIndicatorView.Style) {
        super.init(style: style)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        color = .white
        backgroundColor = .darkGray
        layer.cornerRadius = 10
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 55).isActive = true
        widthAnchor.constraint(equalToConstant: 55).isActive = true
    }
}
