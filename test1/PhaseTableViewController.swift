//
//  PhaseTableViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 9/11/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

class PhaseTableViewController: UITableViewController {
    @IBOutlet var switches: [UISwitch]!
    @IBOutlet weak var boton: UIButton!
    @IBAction func switchDidChange(_ sender: AnyObject) {
        boton.isEnabled = !switches.contains { s in s.isOn == false }
        project.phases[phaseIndex].tasks = switches.map { $0.isOn }
    }
    var project: Project!
    var phaseIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let tasks = project.phases[phaseIndex].tasks
        guard tasks.count > 0 else { return }
        zip(switches, tasks).forEach { s, task in
            s.isOn = task
        }
        boton.isEnabled = !switches.contains { s in s.isOn == false }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextStep" {
            if let nextPhase = segue.destination as? PhaseTableViewController {
                nextPhase.project = project
                nextPhase.phaseIndex = phaseIndex + 1
            }
        }
    }
}
