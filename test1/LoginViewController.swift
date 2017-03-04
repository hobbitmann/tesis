//
//  LoginViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 12/22/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

// Esta es la clase que maneja la pantalla del login
class LoginViewController: UIViewController {

    // Estas variables son "conexiones" (outlets) a objetos dibujados en la pantalla con el "Constructor de Interfaces" o "Interface Builder", de ahí viene la "IB" que sale en @IBOutlet
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    // Esta función está conectada a la "acción" de un botón dibujado en "Interface Builder", por eso dice @IBAction, este es el botón "login"
    @IBAction func didPressLogin(_ sender: Any) {
        // juntamos los parámetros para mandar al servidor
        let parameters: Parameters = [
            "nombre"  : username.text ?? "",
            "password": password.text ?? ""
        ]
        
        // muestra un spinner para que se vea que está "cargando" algo
        SVProgressHUD.show()
        
        // hacemos un request de tipo POST a login.php
        Alamofire.request("\(apiUrl)/login.php", method: .post, parameters: parameters)
            // validamos que nos haya respondido con un código de OK (2xx)
            .validate()
            // y cuando obtengamos un json de vuelta, entramos acá:
            .responseJSON { [unowned self] response in
                let serverResponse = ServerResponse(result: response.result) { (json)->String in
                    guard let id = json["id"] as? String else { throw MappingError() }
                    return id
                }
                switch serverResponse {
                case .success(let data):
                    // en caso de éxito, mostramos un mensaje de éxito dándole la bienvenida al usuario
                    SVProgressHUD.showSuccess(withStatus: "Bienvenido usuario #\(data.first!)")
                    // y hacemos una transición a la siguiente pantalla
                    self.performSegue(withIdentifier: "didLogin", sender: sender)
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

// Este es un objeto sentinela que representa un error en la función de mapeo
struct MappingError: Error {}

// Este es un objeto que puede tomar distintos valores según qué fue lo que respondión el servidor
enum ServerResponse<T> {
    case success(data: [T])
    case failure(error: String)
    case networkError(debugInfo: Error)
    case serverError
    case dataError
    
    // el constructor pide el resultado de una petición al servidor y una función que lo ayude a entender la respuesta (lo que va dentro de "data")
    init(result: Result<Any>, mapper: (Parameters) throws -> T) {
        switch result {
        // si la petición al server fue exitosa
        case .success(let value):
            // intentamos extraer los datos que esperamos que vengan en la respuesta (status, data y error)
            guard
                let respuesta = value as? Parameters,
                let status = respuesta["status"] as? String,
                let data = respuesta["data"] as? [Parameters],
                let error = respuesta["error"] as? String
                else {
                    // si no se pudo hacer eso, entonces tenemos un error en el servidor
                    self = .serverError
                    return
            }
            // si logramos obtener esos datos (status, data y error)
            // vamos a decidir que hacer según lo que venga en "status"
            switch status {
            // si el servidor mandó un status: "success"
            case "success":
                do {
                    // entonces intentamos mapear la data con la función y retornamos un éxito
                    self = .success(data: try data.map(mapper))
                } catch {
                    // si falla el mapeo, entonces reportamos un error en la data
                    self = .dataError
                }
                return
                
            // si el servidor mandó un status: "failure"
            case "failure":
                // mostramos el error que mandó el servidor
                self = .failure(error: error)
                return
            
            // si el servidor mandó un status distinto a "success" o "failure"
            default:
                // entonces reportamos un error en el servidor, porque se supone que tiene que ser uno de esos dos
                self = .serverError
                return
            }
            
        // si la petición al server falló
        case .failure(let error):
            // entonces fue un error de red
            self = .networkError(debugInfo: error)
        }
    }
}
