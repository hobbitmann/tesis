//
//  ProjectsViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 9/11/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

import UIKit
import SVProgressHUD
import Alamofire

// Este es el objeto que va a representar a los proyectos
struct Project {
    var id: String
    var nombre: String
    var fechaInicio: String
    var fechaTermino: String
    var area: String
    var encargado: String
    var rut: String
    var done: String
    var progress: String
}

// Aquí le agregamos un constructor para que pueda crearse un proyecto a partir de un json con este formato:
// {"name": algo, "password": algo, "id": algo}
extension Project {
    init(json: Parameters) throws {
        guard
            let id = json["IDProyectos"] as? String,
            let nombre = json["Nombre"] as? String,
            let fechaInicio = json["FechaInicio"] as? String,
            let fechaTermino = json["FechaTermino"] as? String,
            let area = json["Area"] as? String,
            let encargado = json["Encargado"] as? String,
            let rut = json["usuarios_RUT"] as? String,
            let done = json["done"] as? String
            else {
                // si no logró encontrar esos valores en el json, tira error
                throw MappingError()
        }
        
        // si los encontró, llena sus propios valores y tenemos un objeto de proyecto listo
        self.id = id
        self.nombre = nombre
        self.fechaInicio = fechaInicio
        self.fechaTermino = fechaTermino
        self.area = area
        self.encargado = encargado
        self.rut = rut
        self.done = done
        self.progress = (json["progress"] as? String) ?? ""
    }
}

// Esta es la clase que maneja la celda de proyecto, lo que sale en la lista
class ProjectCell: UITableViewCell {
    // tiene una variable interna de tipo Project
    var project: Project! {
        didSet {
            // cuando se cambia el valor de esa variable interna, se cambia el valor de los textos que va a mostrar en pantalla
            textLabel!.text = project.nombre+project.progress
            detailTextLabel!.text = project.id
            imageView!.image = statusImage(project: project)
        }
    }
    
    private func statusImage(project: Project) -> UIImage {
        let isFinished = project.done == "1"
        if isFinished {
            return #imageLiteral(resourceName: "done")
        }
        
        let today = Date()
        
        var minusOneWeek = DateComponents()
        minusOneWeek.day = -7
        let lastWeekDate = Calendar.current.date(
            byAdding: minusOneWeek,
            to: today
        )
        
        let endDateString = project.fechaTermino
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let endDate = formatter.date(from: endDateString)
        
        guard let end = endDate, let lastWeek = lastWeekDate else {
            return #imageLiteral(resourceName: "warning")
        }
        
        if lastWeek < end {
            return #imageLiteral(resourceName: "good")
        } else if today <= end {
            return #imageLiteral(resourceName: "warning")
        } else {
            return #imageLiteral(resourceName: "bad")
        }
    }
}

// Esta es la clase que maneja la celda de proyecto, lo que sale en la lista
class BigProjectCell: UITableViewCell {
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var nombre: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var fechaInicio: UILabel!
    @IBOutlet weak var fechaTermino: UILabel!
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var encargado: UILabel!
    @IBOutlet weak var rut: UILabel!
    // tiene una variable interna de tipo Project
    var project: Project! {
        didSet {
            // cuando se cambia el valor de esa variable interna, se cambia el valor de los textos que va a mostrar en pantalla
            status.image = statusImage(project: project)
            nombre.text = project.nombre+project.progress
            id.text = project.id
            fechaInicio.text = project.fechaInicio
            fechaTermino.text = project.fechaTermino
            area.text = project.area
            encargado.text = project.encargado
            rut.text = project.rut
        }
    }
    
    private func statusImage(project: Project) -> UIImage {
        let isFinished = project.done == "1"
        if isFinished {
            return #imageLiteral(resourceName: "done")
        }
        
        let today = Date()
        
        var minusOneWeek = DateComponents()
        minusOneWeek.day = -7
        let lastWeekDate = Calendar.current.date(
            byAdding: minusOneWeek,
            to: today
        )
        
        let endDateString = project.fechaTermino
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let endDate = formatter.date(from: endDateString)
        
        guard let end = endDate, let lastWeek = lastWeekDate else {
            return #imageLiteral(resourceName: "warning")
        }
        
        if lastWeek < end {
            return #imageLiteral(resourceName: "good")
        } else if today <= end {
            return #imageLiteral(resourceName: "warning")
        } else {
            return #imageLiteral(resourceName: "bad")
        }
    }
}

// Esta es la clase que maneja la pantalla que muestra los proyectos
class ProjectsViewController: UITableViewController {
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
        // hacemos un request de tipo GET a projects.php
        Alamofire.request("\(apiUrl)/projects.php", parameters: ["id_usuario": loggedInUser])
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
    
    // esta función permite insertar un proyecto nuevo en nuestro arrglo y actualiza la vista para que aparezca
    func insertNewObject(_ project: Project) {
        self.objects.insert(project, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // esta función permite editar un proyecto existente en nuestro arrglo y actualiza la vista para que aparezca
    func updateProject(_ project: Project) {
        if let oldProjectIndex = self.objects.index(where: { $0.id == project.id }) {
            self.objects[oldProjectIndex] = project
            let indexPath = IndexPath(row: oldProjectIndex, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Segues
    
    // esto sucede cuando vamos a hacer una transición a otra vista
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // si es que la transición se llama "newProject"
        if segue.identifier == "newProject" {
            // intentamos obtener la siguiente vista
            if let nc = segue.destination as? UINavigationController,
                let new = nc.viewControllers.first as? NewProjectTableViewController
            {
                // y le pasamos como parámetro la función para insertar proyectos
                // así la pantalla de crear nuevo proyecto puede insertarlo en esta pantalla
                new.callback = insertNewObject
            }
        }
//        // si es que la transición se llama "editProject"
//        if segue.identifier == "editProject" {
//            // intentamos obtener la siguiente vista
//            if let nc = segue.destination as? UINavigationController,
//                let new = nc.viewControllers.first as? NewProjectTableViewController,
//                let cell = sender as? BigProjectCell
//            {
//                // y le pasamos como parámetro la función para editar proyectos
//                // así la pantalla de crear nuevo proyecto puede editarlo en esta pantalla
//                new.callback = updateProject
//                
//                // le cambiamos el título para que diga que
//                new.title = "Editar Proyecto"
//                
//                // y también le pasamos una función para configurar cosas cuando la vista esté cargada
//                new.onViewDidLoad = {
//                    // y además rellenamos la pantalla con los datos que ya tenemos
//                    new.nombre.text = cell.project.nombre
//                    new.fechaInicio.text = cell.project.fechaInicio
//                    new.fechaTermino.text = cell.project.fechaTermino
//                    new.area.text = cell.project.area
//                    new.encargado.text = cell.project.encargado
//                    new.rut.text = cell.project.rut
//                }
//            }
//        }
        // si es que la transición se llama "projectDetail"
        if segue.identifier == "projectDetail" {
            // intentamos obtener la siguiente vista
            if let vc = segue.destination as? TasksViewController,
                let cell = sender as? BigProjectCell
            {
                // y le pasamos como parámetro el proyecto del cual queremos ver detalles
                vc.project = cell.project
            }
        }
        
        // si es que la transición se llama "showPermissions"
        if segue.identifier == "showPermissions" {
            // intentamos obtener la siguiente vista
            if let vc = segue.destination as? PermissionsViewController,
                let cell = sender as? BigProjectCell
            {
                // y le pasamos como parámetro el proyecto del cual queremos ver detalles
                vc.project = cell.project
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
    // esta le enseña como obtener una celda para dibujar y pasarle el proyecto correcto
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? BigProjectCell else {
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
        return true
    }
    
    // esta función tiene que ver con las tablas
    // esta le explica qué hacer dependiendo de qué tipo de edición se está haciendo
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // en caso de que se esté intentando borrar un proyecto, se llama la función deleteProject
            deleteProject(at: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // esta función intenta borrar un proyecto del servidor
    func deleteProject(at indexPath: IndexPath) {
        // manda el id como parámetro
        let parameters: Parameters = [
            "id": objects[indexPath.row].id
        ]
        // muestra un spinner para que se vea que está "cargando" algo
        SVProgressHUD.show()
        // hacemos un request de tipo DELETE a projects.php
        Alamofire.request("\(apiUrl)/projects.php", method: .delete, parameters: parameters)
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
                    SVProgressHUD.showSuccess(withStatus: "Proyecto borrado")
                    // borramos al proyecto del arreglo
                    self.objects.remove(at: indexPath.row)
                    // y actualizamos la vista para que se desaparezca el proyecto
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
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        performSegue(withIdentifier: "showPermissions", sender: cell)
    }
}
