//
//  NewProjectTableViewController.swift
//  test1
//
//  Created by Cristián Arenas Ulloa on 9/11/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

class NewProjectTableViewController: UITableViewController {
    var callback: (Project)->Void = { _ in }
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func done(sender: AnyObject) {
        let p = Project(
            name: name.text ?? "",
            startDate: startDate.date,
            endDate: endDate.date
        )
        callback(p)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
