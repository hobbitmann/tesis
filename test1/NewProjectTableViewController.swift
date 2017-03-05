//
//  NewProjectTableViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 9/11/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

// Esta es la clase que maneja la pantalla de la creación de un proyecto nuevo
class NewProjectTableViewController: UITableViewController {
    // En esta variable podemos meter una función externa, para que cuando se cree un proyecto se entregue por esta vía
    var callback: (Project)->Void = { _ in }
    
    // En esta variable también podemos meter una función externa, para que cuando la vista se cargue, alguien externo pueda configurar cosas
    var onViewDidLoad: ()->Void = { }
    
    // Estas variables son "conexiones" (outlets) a objetos dibujados en la pantalla con el "Constructor de Interfaces" o "Interface Builder", de ahí viene la "IB" que sale en @IBOutlet
    
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var fechaInicio: UITextField!
    @IBOutlet weak var fechaTermino: UITextField!
    @IBOutlet weak var area: UITextField!
    @IBOutlet weak var encargado: UITextField!
    @IBOutlet weak var rut: UITextField!
    
    
    // Esta función está conectada a la "acción" de un botón dibujado en "Interface Builder", por eso dice @IBAction, este es el botón "cancelar"
    @IBAction func cancel(_ sender: AnyObject) {
        // si se apreta cancelar, descartamos (dismiss) la pantalla de creación de proyectos nuevos
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
        // Recopilamos todos los datos necesarios (excepto el id que viene en la respuesta)
        let p_nombre = nombre.text ?? ""
        let p_fechaInicio = fechaInicio.text ?? ""
        let p_fechaTermino = fechaTermino.text ?? ""
        let p_area = area.text ?? ""
        let p_encargado = encargado.text ?? ""
        let p_rut = rut.text ?? ""
        
        // juntamos los parámetros para mandar al servidor
        let parameters: Parameters = [
            "Nombre": p_nombre,
            "FechaInicio": p_fechaInicio,
            "FechaTermino": p_fechaTermino,
            "Area": p_area,
            "Encargado": p_encargado,
            "usuarios_RUT": p_rut,
            "id_usuario": loggedInUser
        ]
        
        // muestra un spinner para que se vea que está "cargando" algo
        SVProgressHUD.show()
        
        // hacemos un request de tipo POST a projects.php
        Alamofire.request("\(apiUrl)/projects.php", method: .post, parameters: parameters)
            // validamos que nos haya respondido con un código de OK (2xx)
            .validate()
            // y cuando obtengamos un json de vuelta, entramos acá:
            .responseJSON { [unowned self] response in
                let serverResponse = ServerResponse(result: response.result) { (json)->String in
                    guard let mensaje = json["id"] as? String else { throw MappingError() }
                    return mensaje
                }
                switch serverResponse {
                case .success(let ids):
                    SVProgressHUD.showSuccess(withStatus: "Proyecto creado")
                    // en caso de éxito, llamamos a la función que nos pasaron, con el objeto project
                    let id = ids[0]
                    let project = Project(
                        id: id,
                        nombre: p_nombre,
                        fechaInicio: p_fechaInicio,
                        fechaTermino: p_fechaTermino,
                        area: p_area,
                        encargado: p_encargado,
                        rut: p_rut
                    )
                    self.callback(project)
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
