//
//  AboutViewController.swift
//  test1
//
//  Created by Gianni Rondalli Arenas on 12/28/16.
//  Copyright © 2016 gianni. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var fechaInicio: UITextField!
    @IBOutlet weak var fechaTermino: UITextField!
    
    @IBAction func didPressLogout(_ sender: Any) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // si es que la transición se llama "newProject"
        if segue.identifier == "showReport" {
            // intentamos obtener la siguiente vista
            if let vc = segue.destination as? ReportViewController {
                vc.fechaInicio = fechaInicio.text ?? ""
                vc.fechaTermino = fechaTermino.text ?? ""
            }
        }
    }
}
