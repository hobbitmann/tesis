//
//  ClientsViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 12/27/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

// Este es el objeto que va a representar a los clientes
struct Client {
    var clientName: String
    var entry: String
    var rut: String
}

// Aquí le agregamos un constructor para que pueda crearse un cliente a partir de un json
extension Client {
    init(json: Parameters) throws {
        guard
            let clientName = json["ClientName"] as? String,
            let entry = json["Entry"] as? String,
            let rut = json["Rut"] as? String
            else {
                // si no logró encontrar esos valores en el json, tira error
                throw MappingError()
        }
        
        // si los encontró, llena sus propios valores y tenemos un objeto de cliente listo
        self.clientName = clientName
        self.entry = entry
        self.rut = rut
    }
}

// Esta es la clase que maneja la celda de cliente, lo que sale en la lista
class ClientCell: UITableViewCell {
    // tiene una variable interna de tipo Client
    var client: Client! {
        didSet {
            // cuando se cambia el valor de esa variable interna, se cambia el valor de los textos que va a mostrar en pantalla
            textLabel!.text = client.clientName
            detailTextLabel!.text = client.rut
        }
    }
}

// Esta es la clase que maneja la pantalla que muestra los clientes
class ClientsViewController: UITableViewController {
    // vamos a empezar con un arreglo de clientes vacío
    var objects = [Client]()
    
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
        // hacemos un request de tipo GET a clients.php
        Alamofire.request("\(apiUrl)/clients.php")
            // validamos que nos haya respondido con un código de OK (2xx)
            .validate()
            // y cuando obtengamos un json de vuelta, entramos acá:
            .responseJSON { [unowned self] response in
                // con el resultado de esta respuesta, creamos un objeto ServerResponse que inventé en el archivo LoginViewController.swift (aunque debiese tirarlo a su propio archivo)
                // pide como parámetro, una función que sepa transformar un pedazo de JSON en un objeto útil, en este caso le estamos pasando el constructor de Client
                let serverResponse = ServerResponse(result: response.result, mapper: Client.init)
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
    
    // esta función permite insertar un cliente nuevo en nuestro arrglo y actualiza la vista para que aparezca
    func insertNewObject(_ client: Client) {
        self.objects.insert(client, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // esta función permite editar un cliente existente en nuestro arrglo y actualiza la vista para que aparezca
    func updateClient(_ client: Client) {
        if let oldClientIndex = self.objects.index(where: { $0.rut == client.rut }) {
            self.objects[oldClientIndex] = client
            let indexPath = IndexPath(row: oldClientIndex, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Segues
    
    // esto sucede cuando vamos a hacer una transición a otra vista
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // si es que la transición se llama "newClient"
        if segue.identifier == "newClient" {
            // intentamos obtener la siguiente vista
            if let nc = segue.destination as? UINavigationController,
                let new = nc.viewControllers.first as? NewClientTableViewController
            {
                // y le pasamos como parámetro la función para insertar clientes
                // así la pantalla de crear nuevo cliente puede insertarlo en esta pantalla
                new.callback = insertNewObject
            }
        }
        // si es que la transición se llama "editClient"
        if segue.identifier == "editClient" {
            // intentamos obtener la siguiente vista
            if let nc = segue.destination as? UINavigationController,
                let new = nc.viewControllers.first as? NewClientTableViewController,
                let cell = sender as? ClientCell
            {
                // y le pasamos como parámetro la función para editar clientes
                // así la pantalla de crear nuevo cliente puede editarlo en esta pantalla
                new.callback = updateClient
                
                // le cambiamos el título para que diga que
                new.title = "Editar Cliente"
                
                // y también le pasamos una función para configurar cosas cuando la vista esté cargada
                new.onViewDidLoad = {
                    // y además rellenamos la pantalla con los datos que ya tenemos
                    new.clientName.text = cell.client.clientName
                    new.entry.text = cell.client.entry
                    new.rut.text = cell.client.rut
                    
                    // y desabilitamos el rut para que no se pueda modificar (y lo ponemos gris pa que se entienda)
                    new.rut.isEnabled = false
                    new.rut.textColor = UIColor.gray
                }
            }
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
    // esta le enseña como obtener una celda para dibujar y pasarle el cliente correcto
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ClientCell else {
            fatalError("ups")
        }
        
        let object = objects[indexPath.row]
        cell.client = object
        return cell
    }

    // esta función tiene que ver con las tablas
    // esta dice que todas las celdas son editables
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // esta función tiene que ver con las tablas
    // esta le explica qué hacer dependiendo de qué tipo de edición se está haciendo
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // en caso de que se esté intentando borrar un cliente, se llama la función deleteClient
            deleteClient(at: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // esta función intenta borrar un cliente del servidor
    func deleteClient(at indexPath: IndexPath) {
        // manda el id como parámetro
        let parameters: Parameters = [
            "Rut": objects[indexPath.row].rut
        ]
        // muestra un spinner para que se vea que está "cargando" algo
        SVProgressHUD.show()
        // hacemos un request de tipo DELETE a clients.php
        Alamofire.request("\(apiUrl)/clients.php", method: .delete, parameters: parameters)
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
                    //en caso de exito, mostramos un mensaje de éxito
                    SVProgressHUD.showSuccess(withStatus: "Cliente borrado")
                    // borramos al cliente del arreglo
                    self.objects.remove(at: indexPath.row)
                    // y actualizamos la vista para que se desaparezca el cliente
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

