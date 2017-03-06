//
//  ReportViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 6/3/17.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

// Esta es la clase que maneja la pantalla que muestra los proyectos
class ReportViewController: UITableViewController {
    var fechaInicio: String!
    var fechaTermino: String!
    
    // vamos a empezar con un arreglo de proyectos vacío
    var objects = [Project]()
    
    // esta función se llama sola cuando la vista cargó
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // aquí configuro esa weaita del pullToRefresh, pa que si tirai pa abajo recargue
        refreshControl = UIRefreshControl()
        // y le digo que cuando se tire para abajo, se llame a la función "didPullToRefresh"
        refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        refreshControl?.beginRefreshing()
        
        // y cargamos los datos por primera vez
        loadData()
    }
    
    // esta función se llama cuando tiras para abajo para recargar
    @objc func didPullToRefresh(sender: Any) {
        // y cuando pedimos que se recargue, queremos que se vuelvan a bajar los datos
        loadData()
    }
    
    // esta es la función que obtiene los datos de internet
    func loadData() {
        let parameters: Parameters = [
            "FechaInicio": fechaInicio,
            "FechaTermino": fechaTermino
        ]
        
        // hacemos un request de tipo GET a projects.php
        Alamofire.request("\(apiUrl)/report.php", parameters: parameters)
            // validamos que nos haya respondido con un código de OK (2xx)
            .validate()
            // y cuando obtengamos un json de vuelta, entramos acá:
            .responseJSON { [unowned self] response in
                // con el resultado de esta respuesta, creamos un objeto ServerResponse que inventé en el archivo LoginViewController.swift (aunque debiese tirarlo a su propio archivo)
                // pide como parámetro, una función que sepa transformar un pedazo de JSON en un objeto útil, en este caso le estamos pasando el constructor de Project
                let serverResponse = ServerResponse(result: response.result, mapper: Project.init)
                // al crearse, ese objeto puede tener 5 valores distintos posibles:
                
                
                switch serverResponse {
                // .success, si todo salió bien, y viene con la respuesta en data
                case .success(let data):
                    // en este caso, cambiamos nuestro arreglo de datos por el que vino de internet
                    self.objects = data
                    // y recargamos la vista para mostrarlos
                    self.tableView.reloadData()
                    
                // .failure, si el servidor respondió correctamente con un status "failure" y un mensaje de error
                case .failure(let error):
                    // mostramos el mensaje de error del servidor
                    SVProgressHUD.showError(withStatus: "Error\n\(error)")
                    
                // .networkError, si es que no se pudo hacer la request, probablemente por problemas de conexión
                case .networkError(let debugInfo):
                    // mostramos un mensaje de error diciendo que es culpa de la conexión
                    print(debugInfo)
                    SVProgressHUD.showError(withStatus: "Error\nrevise su conexión")
                    
                // .serverError, si es que el servidor respondió con algo que no podemos entender
                case .serverError:
                    // hacemos lo mismo que en el próximo caso
                    fallthrough
                    
                // y .dataError, si es que todo estaba funcionando bien, pero la función que transforma el JSON en algo útil, falló
                case .dataError:
                    // mostramos un mensaje de error de que la culpa es del server
                    SVProgressHUD.showError(withStatus: "Error del servidor\nintente más tarde")
                }
                self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table View
    // esta función tiene que ver con las tablas
    // esta dice que solo hay una sección de datos
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // esta función tiene que ver con las tablas
    // esta dice que que en esa sección, hay tantas filas como elementos hay en nuestro arreglo
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    // esta función tiene que ver con las tablas
    // esta le enseña como obtener una celda para dibujar y pasarle el proyecto correcto
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ProjectCell else {
            fatalError("ups")
        }
        
        let object = objects[indexPath.row]
        cell.project = object
        return cell
    }
    
    // esta función tiene que ver con las tablas
    // esta dice que todas las celdas son editables
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
}
