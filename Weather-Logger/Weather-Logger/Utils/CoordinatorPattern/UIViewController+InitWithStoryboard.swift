//
//  StoryboardedProtocol.swift
//
//  Created by Hardijs on 18/12/2020.
//

import UIKit

extension UIViewController {
    static func instantiateWithMainStoryBoard() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "\(self.self)") as! Self
    }
}
