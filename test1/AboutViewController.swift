//
//  AboutViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 12/28/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBAction func didPressLogout(_ sender: Any) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
}
