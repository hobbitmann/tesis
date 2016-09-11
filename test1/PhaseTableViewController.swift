//
//  PhaseTableViewController.swift
//  test1
//
//  Created by Cristián Arenas Ulloa on 9/11/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

class PhaseTableViewController: UITableViewController {
    @IBOutlet var switches: [UISwitch]!
    @IBOutlet weak var boton: UIButton!
    @IBAction func switchDidChange(sender: AnyObject) {
        boton.enabled = !switches.contains { s in s.on == false }
    }
}
