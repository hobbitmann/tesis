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
    var startDate: NSDate
    var endDate: NSDate
    var phases: [Phase]
    
    init(name: String, startDate: NSDate, endDate: NSDate) {
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
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(project: Project) {
        self.objects.insert(project, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let nc = segue.destinationViewController as? UINavigationController,
               let phase = nc.viewControllers.first as? PhaseTableViewController,
               let cell = sender as? ProjectCell
            {
                phase.project = cell.project
            }
        }
        if segue.identifier == "newProject" {
            if let nc = segue.destinationViewController as? UINavigationController,
               let new = nc.viewControllers.first as? NewProjectTableViewController
            {
                new.callback = insertNewObject
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? ProjectCell else {
            fatalError("ups")
        }

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.name
        cell.project = object
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

