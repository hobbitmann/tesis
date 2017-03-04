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

// Este es el objeto que va a representar a los usuarios
struct User {
    var username: String
    var password: String
    var id: String
}

// Aquí le agregamos un constructor para que pueda crearse un usuario a partir de un json con este formato:
// {"username": algo, "password": algo, "id": algo}
extension User {
    init(json: Parameters) throws {
        guard
            let username = json["username"] as? String,
            let password = json["password"] as? String,
            let id = json["id"] as? String
            else {
                // si no logró encontrar esos valores en el json, tira error
                throw MappingError()
        }
        
        // si los encontró, llena sus propios valores y tenemos un objeto de usuario listo
        self.username = username
        self.password = password
        self.id = id
    }
}

// Esta es la clase que maneja la celda de usuario, lo que sale en la lista
class UserCell: UITableViewCell {
    // tiene una variable interna de tipo User
    var user: User! {
        didSet {
            // cuando se cambia el valor de esa variable interna, se cambia el valor de los textos que va a mostrar en pantalla
            textLabel!.text = user.username
            detailTextLabel!.text = user.id
        }
    }
}

// Esta es la clase que maneja la pantalla que muestra los usuarios
class UsersViewController: UITableViewController {
    // vamos a empezar con un arreglo de usuarios vacío
    var objects = [User]()
    
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
        // hacemos un request de tipo GET a users.php
        Alamofire.request("\(apiUrl)/users.php")
            // validamos que nos haya respondido con un código de OK (2xx)
            .validate()
            // y cuando obtengamos un json de vuelta, entramos acá:
            .responseJSON { [unowned self] response in
                // con el resultado de esta respuesta, creamos un objeto ServerResponse que inventé en el archivo LoginViewController.swift (aunque debiese tirarlo a su propio archivo)
                // pide como parámetro, una función que sepa transformar un pedazo de JSON en un objeto útil, en este caso le estamos pasando el constructor de User
                let serverResponse = ServerResponse(result: response.result, mapper: User.init)
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
    
    // esta función permite insertar un usuario nuevo en nuestro arrglo y actualiza la vista para que aparezca
    func insertNewObject(_ user: User) {
        self.objects.insert(user, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // esta función permite editar un usuario existente en nuestro arrglo y actualiza la vista para que aparezca
    func updateUser(_ user: User) {
        if let oldUserIndex = self.objects.index(where: { $0.id == user.id }) {
            self.objects[oldUserIndex] = user
            let indexPath = IndexPath(row: oldUserIndex, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Segues
    
    // esto sucede cuando vamos a hacer una transición a otra vista
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // si es que la transición se llama "newUser"
        if segue.identifier == "newUser" {
            // intentamos obtener la siguiente vista
            if let nc = segue.destination as? UINavigationController,
                let new = nc.viewControllers.first as? NewUserTableViewController
            {
                // y le pasamos como parámetro la función para insertar usuarios
                // así la pantalla de crear nuevo usuario puede insertarlo en esta pantalla
                new.callback = insertNewObject
            }
        }
        // si es que la transición se llama "editUser"
        if segue.identifier == "editUser" {
            // intentamos obtener la siguiente vista
            if let nc = segue.destination as? UINavigationController,
                let new = nc.viewControllers.first as? NewUserTableViewController,
                let cell = sender as? UserCell
            {
                // y le pasamos como parámetro la función para editar usuarios
                // así la pantalla de crear nuevo usuario puede editarlo en esta pantalla
                new.callback = updateUser
                
                // le cambiamos el título para que diga que
                new.title = "Editar Usuario"
                
                // y también le pasamos una función para configurar cosas cuando la vista esté cargada
                new.onViewDidLoad = {
                    // y además rellenamos la pantalla con los datos que ya tenemos
                    new.username.text = cell.user.username
                    new.password.text = cell.user.password
                    new.id.text = cell.user.id
                    
                    // y desabilitamos el id para que no se pueda modificar (y lo ponemos gris pa que se entienda)
                    new.id.isEnabled = false
                    new.id.textColor = UIColor.gray
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
    // esta le enseña como obtener una celda para dibujar y pasarle el usuario correcto
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UserCell else {
            fatalError("ups")
        }
        
        let object = objects[indexPath.row]
        cell.user = object
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
            // en caso de que se esté intentando borrar un usuario, se llama la función deleteUser
            deleteUser(at: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // esta función intenta borrar un usuario del servidor
    func deleteUser(at indexPath: IndexPath) {
        // manda el id como parámetro
        let parameters: Parameters = [
            "id": objects[indexPath.row].id
        ]
        // muestra un spinner para que se vea que está "cargando" algo
        SVProgressHUD.show()
        // hacemos un request de tipo DELETE a users.php
        Alamofire.request("\(apiUrl)/users.php", method: .delete, parameters: parameters)
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
                    SVProgressHUD.showSuccess(withStatus: "Usuario borrado")
                    // borramos al usuario del arreglo
                    self.objects.remove(at: indexPath.row)
                    // y actualizamos la vista para que se desaparezca el usuario
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

