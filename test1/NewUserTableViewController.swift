//
//  NewUserTableViewController.swift
//  test1
//
//  Created by Cristián Arenas Ulloa on 12/27/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

class NewUserTableViewController: UITableViewController {
    var callback: (User)->Void = { _ in }
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var id: UITextField!
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func done(_ sender: AnyObject) {
        let p = User(
            username: username.text ?? "",
            password: password.text ?? "",
            id: id.text ?? ""
        )
        callback(p)
        dismiss(animated: true, completion: nil)
    }
}
