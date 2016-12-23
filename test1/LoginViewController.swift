//
//  LoginViewController.swift
//  test1
//
//  Created by Cristián Arenas Ulloa on 12/22/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit
import Alamofire

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
        Alamofire.request("http://pt202.dreamhosters.com/api/login.php", method: .post, parameters: parameters)
            .validate()
            .responseString { [unowned self] response in
                switch response.result {
                case .success(let value):
                    print("login correcto: \(value)")
                    if value=="OK" {
                        self.performSegue(withIdentifier: "didLogin", sender: sender)
                    }
                case .failure(let error):
                    print("login fallido: \(error)")
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
