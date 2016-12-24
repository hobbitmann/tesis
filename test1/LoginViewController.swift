//
//  LoginViewController.swift
//  test1
//
//  Created by Cristián Arenas Ulloa on 12/22/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressLogin(_ sender: Any) {
        let parameters: Parameters = [
            "nombre"  : username.text ?? "",
            "password": password.text ?? ""
        ]
        SVProgressHUD.show()
        Alamofire.request("http://pt202.dreamhosters.com/api/controllers/login.php", method: .post, parameters: parameters)
            .validate()
            .responseJSON { [unowned self] response in
                switch ServerResponse(result: response.result) {
                case .success(let data):
                    SVProgressHUD.showSuccess(withStatus: "Bienvenido usuario #\(data[0]["id"]!)")
                    self.performSegue(withIdentifier: "didLogin", sender: sender)
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: "Error\n\(error)")
                case .networkError(let debugInfo):
                    print(debugInfo)
                    SVProgressHUD.showError(withStatus: "Error\nrevise su conexión")
                case .serverError:
                    SVProgressHUD.showError(withStatus: "Error del servidor\nintente más tarde")
                }
        }
    }

    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destinationViewController.
         Pass the selected object to the new view controller.
    }
    */

}

enum ServerResponse {
    case success(data: [Parameters])
    case failure(error: String)
    case networkError(debugInfo: Error)
    case serverError
    
    init(result: Result<Any>) {
        switch result {
        case .success(let value):
            guard
                let respuesta = value as? Parameters,
                let status = respuesta["status"] as? String,
                let data = respuesta["data"] as? [Parameters],
                let error = respuesta["error"] as? String
                else {
                    self = .serverError
                    return
            }
            switch status {
            case "success":
                self = .success(data: data)
                return
            case "failure":
                self = .failure(error: error)
                return
            default:
                self = .serverError
                return
            }
        case .failure(let error):
            self = .networkError(debugInfo: error)
        }
    }
}
