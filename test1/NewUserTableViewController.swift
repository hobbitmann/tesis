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

// Esta es la clase que maneja la pantalla de la creación de un usuario nuevo
class NewUserTableViewController: UITableViewController {
    // En esta variable podemos meter una función externa, para que cuando se cree un usuario se entregue por esta vía
    var callback: (User)->Void = { _ in }
    
    // En esta variable también podemos meter una función externa, para que cuando la vista se cargue, alguien externo pueda configurar cosas
    var onViewDidLoad: ()->Void = { }
    
    // Estas variables son "conexiones" (outlets) a objetos dibujados en la pantalla con el "Constructor de Interfaces" o "Interface Builder", de ahí viene la "IB" que sale en @IBOutlet
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var id: UITextField!
    
    // Esta función está conectada a la "acción" de un botón dibujado en "Interface Builder", por eso dice @IBAction, este es el botón "cancelar"
    @IBAction func cancel(_ sender: AnyObject) {
        // si se apreta cancelar, descartamos (dismiss) la pantalla de creación de usuarios nuevos
        dismiss(animated: true, completion: nil)
    }
    
    // esta función se llama cuando se carga la vista
    override func viewDidLoad() {
        super.viewDidLoad()
        // y llamamos a nuestra función onViewDidLoad, por si el que nos está mostrando quiere hacer algo con nosotros
        onViewDidLoad()
    }
    
    // Otra función conectada a un botón, este es el botón "listo" (done)
    @IBAction func done(_ sender: AnyObject) {
        
        // Creamos un objeto User con los textos que 
        let user = User(
            username: username.text ?? "",
            password: password.text ?? "",
            id: id.text ?? ""
        )
        // juntamos los parámetros para mandar al servidor
        let parameters: Parameters = [
            "username": user.username,
            "password": user.password,
            "id": user.id
        ]
        
        // muestra un spinner para que se vea que está "cargando" algo
        SVProgressHUD.show()
        
        // hacemos un request de tipo POST a users.php
        Alamofire.request("http://pt202.dreamhosters.com/api/controllers/users.php", method: .post, parameters: parameters)
            // validamos que nos haya respondido con un código de OK (2xx)
            .validate()
            // y cuando obtengamos un json de vuelta, entramos acá:
            .responseJSON { [unowned self] response in
                let serverResponse = ServerResponse(result: response.result) { (json)->String in
                    guard let mensaje = json["mensaje"] as? String else { throw MappingError() }
                    return mensaje
                }
                switch serverResponse {
                case .success(let data):
                    print(data)
                    SVProgressHUD.showSuccess(withStatus: "Usuario creado")
                    // en caso de éxito, llamamos a la función que nos pasaron, con el objeto user
                    self.callback(user)
                    // y descartamos la pantalla que ya cumplió su propósito
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
