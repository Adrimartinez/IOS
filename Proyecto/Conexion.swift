//
//  conexion.swift
//  Proyecto
//
//  Created by dam on 16/2/17.
//  Copyright © 2017 dam. All rights reserved.
//

import Foundation

class Conexion {
    
    
    
    init(){}
    
    
    func borrar (actividad: Actividad){
        DispatchQueue.global(qos: .background).async{
            
            let sURL: String = "https://fcmdam-alextsanchez.c9users.io/ios/actividad/"+String(describing: actividad.id!)
            let myUrl = NSURL(string: sURL)
            let request = NSMutableURLRequest(url: myUrl as! URL)
            request.httpMethod = "DELETE"
            let task = URLSession.shared.dataTask(with: request as URLRequest){
                (data,response,error) -> Void in
                
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
            }
            task.resume()
        }
    }
    
}
