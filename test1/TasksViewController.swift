//
//  TasksViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 9/11/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

import UIKit
import SVProgressHUD
import Alamofire

// Este es el objeto que va a representar a los tareas
struct Phase {
    var id: String
    var nombre: String
    var tasks: [Task]
}

struct Task {
    var id: Int
    var name: String
    var status: Bool
}

// Aquí le agregamos un constructor para que pueda crearse una fase a partir de un json
extension Phase {
    init(json: Parameters) throws {
        guard
            let id = json["id"] as? String,
            let nombre = json["nombre"] as? String,
            let tasks = json["tasks"] as? [Parameters]
            else {
                // si no logró encontrar esos valores en el json, tira error
                throw MappingError()
        }
        
        // si los encontró, llena sus propios valores y tenemos un objeto de fase listo
        self.id = id
        self.nombre = nombre
        self.tasks = tasks.flatMap { json in
            return try? Task(json: json)
        }
    }
}

// Aquí le agregamos un constructor para que pueda crearse un tarea a partir de un json
extension Task {
    init(json: Parameters) throws {
        guard
            let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let status = json["status"] as? Bool
            else {
                // si no logró encontrar esos valores en el json, tira error
                throw MappingError()
        }
        
        // si los encontró, llena sus propios valores y tenemos un objeto de tarea listo
        self.id = id
        self.name = name
        self.status = status
    }
}

// Esta es la clase que maneja la celda de tarea, lo que sale en la lista
class TaskCell: UITableViewCell {
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    var taskCompleter: (Task) -> Void = { _ in }
    
    @IBAction func taskDidComplete(_ sender: Any) {
        statusSwitch.isEnabled = false
        taskCompleter(task)
    }
    
    // tiene una variable interna de tipo Task
    var task: Task! {
        didSet {
            // cuando se cambia el valor de esa variable interna, se cambia el valor de los textos que va a mostrar en pantalla
            nombreLabel.text = task.name
            idLabel.text = String(task.id)
            statusSwitch.isOn = task.status
        }
    }
}

// Esta es la clase que maneja la pantalla que muestra los tareas
class TasksViewController: UITableViewController {
    // vamos a empezar con un arreglo de tareas vacío
    var completableTask: Task? = nil
    var objects = [Phase]() {
        didSet {
            let allTasks = objects.flatMap { phase in
                return phase.tasks
            }
            completableTask = allTasks.first { task in
                return task.status == false
            }
        }
    }
    
    // tenemos esta variable para que nos pasen el proyecto que queremos ver
    var project: Project!
    
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
        // manda el id como parámetro
        let parameters: Parameters = [
            "id_proyecto": project.id
        ]
        // hacemos un request de tipo GET a tasks.php
        Alamofire.request("\(baseURL)/tasks.php", parameters: parameters)
            // validamos que nos haya respondido con un código de OK (2xx)
            .validate()
            // y cuando obtengamos un json de vuelta, entramos acá:
            .responseJSON { [unowned self] response in
                // con el resultado de esta respuesta, creamos un objeto ServerResponse que inventé en el archivo LoginViewController.swift (aunque debiese tirarlo a su propio archivo)
                // pide como parámetro, una función que sepa transformar un pedazo de JSON en un objeto útil, en este caso le estamos pasando el constructor de Phase
                let serverResponse = ServerResponse(result: response.result, mapper: Phase.init)
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
    
//    // esta función permite insertar un tarea nuevo en nuestro arrglo y actualiza la vista para que aparezca
//    func insertNewObject(_ task: Task) {
//        self.objects.insert(task, at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        self.tableView.insertRows(at: [indexPath], with: .automatic)
//    }
//    
//    // esta función permite editar un tarea existente en nuestro arrglo y actualiza la vista para que aparezca
//    func updateTask(_ task: Task) {
//        if let oldTaskIndex = self.objects.index(where: { $0.id == task.id }) {
//            self.objects[oldTaskIndex] = task
//            let indexPath = IndexPath(row: oldTaskIndex, section: 0)
//            self.tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
//    }
    
    // MARK: - Segues
    
    // esto sucede cuando vamos a hacer una transición a otra vista
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // si es que la transición se llama "newTask"
//        if segue.identifier == "newTask" {
//            // intentamos obtener la siguiente vista
//            if let nc = segue.destination as? UINavigationController,
//                let new = nc.viewControllers.first as? NewTaskTableViewController
//            {
//                // y le pasamos como parámetro la función para insertar tareas
//                // así la pantalla de crear nuevo tarea puede insertarlo en esta pantalla
//                new.callback = insertNewObject
//            }
//        }
//        // si es que la transición se llama "editTask"
//        if segue.identifier == "editTask" {
//            // intentamos obtener la siguiente vista
//            if let nc = segue.destination as? UINavigationController,
//                let new = nc.viewControllers.first as? NewTaskTableViewController,
//                let cell = sender as? TaskCell
//            {
//                // y le pasamos como parámetro la función para editar tareas
//                // así la pantalla de crear nuevo tarea puede editarlo en esta pantalla
//                new.callback = updateTask
//                
//                // le cambiamos el título para que diga que
//                new.title = "Editar Tarea"
//                
//                // y también le pasamos una función para configurar cosas cuando la vista esté cargada
//                new.onViewDidLoad = {
//                    // y además rellenamos la pantalla con los datos que ya tenemos
//                    new.nombre.text = cell.task.nombre
//                    new.fechaInicio.text = cell.task.fechaInicio
//                    new.fechaTermino.text = cell.task.fechaTermino
//                    new.area.text = cell.task.area
//                    new.encargado.text = cell.task.encargado
//                    new.rut.text = cell.task.rut
//                }
//            }
//        }
//    }
    
    // MARK: - Table View
    // esta función tiene que ver con las tablas
    // esta dice que hay una sección de datos por cada fase
    override func numberOfSections(in tableView: UITableView) -> Int {
        return objects.count
    }
    
    // esta función tiene que ver con las tablas
    // esta dice que que en esa sección, hay tantas filas como elementos hay en el arreglo de tareas de la sección correspondiente
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects[section].tasks.count
    }
    
    // esta función tiene que ver con las tablas
    // esta le enseña como obtener una celda para dibujar y pasarle el tarea correcto
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TaskCell else {
            fatalError("ups")
        }
        
        let object = objects[indexPath.section].tasks[indexPath.row]
        cell.task = object
        let isTaskCompletable = completableTask?.id == object.id
        cell.statusSwitch.isEnabled = isTaskCompletable
        cell.taskCompleter = self.completeTask
        return cell
    }
    
    // esta función tiene que ver con las tablas
    // esta dice que esa sección tiene un título similar a este: "Sección Juanito (4)" donde el número es el id de la sección
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let object = objects[section]
        
        return "\(object.nombre) (\(object.id))"
    }
    
    
    // esta función tiene que ver con las tablas
    // esta dice que ninguna celda es editables
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // esta función intenta borrar un tarea del servidor
    func completeTask(task: Task) {
        // manda el id como parámetro
        let parameters: Parameters = [
            "id_task": task.id
        ]
        // muestra un spinner para que se vea que está "cargando" algo
        SVProgressHUD.show()
        // hacemos un request de tipo POST a tasks.php
        Alamofire.request("\(baseURL)/tasks.php", method: .post, parameters: parameters)
            // validamos que nos haya respondido con un código de OK (2xx)
            .validate()
            // y cuando obtengamos un json de vuelta, entramos acá:
            .responseJSON { [weak self] response in
                let serverResponse = ServerResponse(result: response.result) { (json)->String in
                    guard let mensaje = json["mensaje"] as? String else { throw MappingError() }
                    return mensaje
                }
                switch serverResponse {
                case .success(let data):
                    print(data)
                    // en caso de exito, mostramos un mensaje de éxito
                    SVProgressHUD.showSuccess(withStatus: "Tarea borrado")
                    
                    // y recargamos la tabla
                    self?.refreshControl?.beginRefreshing()
                    self?.loadData()
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
