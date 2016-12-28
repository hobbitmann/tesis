//
//  NewUserTableViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 12/27/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class NewUserTableViewController: UITableViewController {
    var callback: (User)->Void = { _ in }
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var id: UITextField!
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func done(_ sender: AnyObject) {
        let user = User(
            username: username.text ?? "",
            password: password.text ?? "",
            id: id.text ?? ""
        )
        let parameters: Parameters = [
            "username": user.username,
            "password": user.password,
            "id": user.id
        ]
        SVProgressHUD.show()
        Alamofire.request("http://pt202.dreamhosters.com/api/controllers/users.php", method: .post, parameters: parameters)
            .validate()
            .responseJSON { [unowned self] response in
                let serverResponse = ServerResponse(result: response.result) { (json)->String in
                    guard let mensaje = json["mensaje"] as? String else { throw MappingError() }
                    return mensaje
                }
                switch serverResponse {
                case .success(let data):
                    print(data)
                    SVProgressHUD.showSuccess(withStatus: "Usuario creado")
                    self.callback(user)
                    self.dismiss(animated: true, completion: nil)
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
