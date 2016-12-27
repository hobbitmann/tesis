//
//  UsersViewController.swift
//  test1
//
//  Created by Cristián Arenas Ulloa on 12/27/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

struct User {
    var username: String
    var password: String
    var id: String
}

class UserCell: UITableViewCell {
    var user: User! {
        didSet {
            textLabel!.text = user.username
            detailTextLabel!.text = user.id
        }
    }
}

class UsersViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
    }
    
    func insertNewObject(_ user: User) {
        self.objects.insert(user, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            if let phase = segue.destination as? PhaseTableViewController,
//                let cell = sender as? ProjectCell
//            {
//                phase.project = cell.project
//            }
//        }
        if segue.identifier == "newUser" {
            if let nc = segue.destination as? UINavigationController,
                let new = nc.viewControllers.first as? NewUserTableViewController
            {
                new.callback = insertNewObject
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UserCell else {
            fatalError("ups")
        }
        
        let object = objects[indexPath.row]
        cell.user = object
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

