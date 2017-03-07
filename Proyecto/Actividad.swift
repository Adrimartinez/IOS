//
//  Actividad.swift
//  Proyecto
//
//  Created by dam on 2/2/17.
//  Copyright © 2017 dam. All rights reserved.
//

import UIKit


class Actividad {
    //MARK: Properties
    
    var id: Int?
    var nombre: String?
    var idp: Int?
    var titulo: String?
    var descripcion: String?
    var grupo: String?
    var lugar: String?
    var fecha: String?
    var horaIni: String?
    var horaFin: String?
    

    
    init(id: Int, nombre: String, idp: Int, titulo: String, descripcion: String, grupo: String, lugar: String, fecha: String, horaIni: String, horaFin: String){
        
        self.id = id
        self.nombre = nombre
        self.idp = idp
        self.titulo = titulo
        self.descripcion = descripcion
        self.grupo = grupo
        self.lugar = lugar
        self.fecha = fecha
        self.horaIni = horaIni
        self.horaFin = horaFin
        
    }
    
}
