//
//  ProfesorModel.swift
//  Proyecto
//
//  Created by dam on 31/1/17.
//  Copyright © 2017 dam. All rights reserved.
//

import UIKit

class Profesor {
    //MARK: Properties
    
    var id: Int?
    var nombre: String?
    var departamento : String?
    
    
    init?(id: Int, nombre: String, departamento: String){
        
        self.id = id
        self.nombre = nombre
        self.departamento = departamento
    
    }

}
