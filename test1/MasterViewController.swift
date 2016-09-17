//
//  MasterViewController.swift
//  test1
//
//  Created byarstar Cristián Arenas Ulloa on 9/11/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

struct Phase {
    var tasks: [Bool]
}
class Project {
    var name: String
    var startDate: Date
    var endDate: Date
    var phases: [Phase]
    
    init(name: String, startDate: Date, endDate: Date) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        phases = [
            Phase(tasks: []),
            Phase(tasks: []),
            Phase(tasks: []),
        ]
    }
}

class ProjectCell: UITableViewCell {
    var project: Project!
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Project]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ project: Project) {
        self.objects.insert(project, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let nc = segue.destination as? UINavigationController,
               let phase = nc.viewControllers.first as? PhaseTableViewController,
               let cell = sender as? ProjectCell
            {
                phase.project = cell.project
            }
        }
        if segue.identifier == "newProject" {
            if let nc = segue.destination as? UINavigationController,
               let new = nc.viewControllers.first as? NewProjectTableViewController
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ProjectCell else {
            fatalError("ups")
        }

        let object = objects[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = object.name
        cell.project = object
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

