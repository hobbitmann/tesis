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
        project.phases[phaseIndex].tasks = switches.map { $0.on }
    }
    var project: Project!
    var phaseIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let tasks = project.phases[phaseIndex].tasks
        guard tasks.count > 0 else { return }
        zip(switches, tasks).forEach { s, task in
            s.on = task
        }
        boton.enabled = !switches.contains { s in s.on == false }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "nextStep" {
            if let nextPhase = segue.destinationViewController as? PhaseTableViewController {
                nextPhase.project = project
                nextPhase.phaseIndex = phaseIndex + 1
            }
        }
    }
}
