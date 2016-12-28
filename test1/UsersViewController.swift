//
//  UsersViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 12/27/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

struct User {
    var username: String
    var password: String
    var id: String
}

extension User {
    init(json: Parameters) throws {
        guard
            let username = json["username"] as? String,
            let password = json["password"] as? String,
            let id = json["id"] as? String
            else {
                throw MappingError()
        }
        
        self.username = username
        self.password = password
        self.id = id
    }
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
//        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        refreshControl?.beginRefreshing()
        loadData()
    }
    
    @objc func didPullToRefresh(sender: Any) {
        loadData()
    }
    
    func loadData() {
        Alamofire.request("http://pt202.dreamhosters.com/api/controllers/users.php")
            .validate()
            .responseJSON { [unowned self] response in
                let serverResponse = ServerResponse(result: response.result, mapper: User.init)
                switch serverResponse {
                case .success(let data):
                    self.objects = data
                    self.tableView.reloadData()
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: "Error\n\(error)")
                case .networkError(let debugInfo):
                    print(debugInfo)
                    SVProgressHUD.showError(withStatus: "Error\nrevise su conexión")
                case .serverError:
                    fallthrough
                case .dataError:
                    SVProgressHUD.showError(withStatus: "Error del servidor\nintente más tarde")
                }
                self.refreshControl?.endRefreshing()
        }
    }
    
    func insertNewObject(_ user: User) {
        self.objects.insert(user, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
            deleteUser(at: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func deleteUser(at indexPath: IndexPath) {
        let parameters: Parameters = [
            "id": objects[indexPath.row].id
        ]
        SVProgressHUD.show()
        Alamofire.request("http://pt202.dreamhosters.com/api/controllers/users.php", method: .delete, parameters: parameters)
            .validate()
            .responseJSON { [unowned self] response in
                let serverResponse = ServerResponse(result: response.result) { (json)->String in
                    guard let mensaje = json["mensaje"] as? String else { throw MappingError() }
                    return mensaje
                }
                switch serverResponse {
                case .success(let data):
                    print(data)
                    SVProgressHUD.showSuccess(withStatus: "Usuario borrado")
                    self.objects.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: "Error\n\(error)")
                case .networkError(let debugInfo):
                    print(debugInfo)
                    SVProgressHUD.showError(withStatus: "Error\nrevise su conexión")
                case .serverError:
                    fallthrough
                case .dataError:
                    SVProgressHUD.showError(withStatus: "Error del servidor\nintente más tarde")
                }
        }

    }
}

