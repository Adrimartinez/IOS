//
//  ActividadesTableViewController.swift
//  Proyecto
//
//  Created by dam on 31/1/17.
//  Copyright © 2017 dam. All rights reserved.
//

import os.log

import UIKit

import Foundation

class ActividadesTableViewController: UITableViewController {
    
    let con: Conexion = Conexion()
    
    var actividadesArray: [Actividad] = []
    
    var actividadesFiltered: [Actividad] = []
    
    var searchActive : Bool = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
        
    //@IBOutlet weak var tabla: UITableView!

  
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl: UIRefreshControl = UIRefreshControl()
        
        if #available(iOS 10.0, *) {
            
            self.tableView.refreshControl = refreshControl
        }else{
            self.tableView.addSubview(refreshControl)
        }
        
        self.refreshControl?.tintColor = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 1.0)
        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Recargando actividades")
        
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        get()
        
        self.tableView.reloadData()
    }
    
    func loadImageFromUrl(url: String, view: UIImageView){
        
        // Create Url from string
        let url = NSURL(string: url)!
        
        // Download task:
        // - sharedSession = global NSURLCache, NSHTTPCookieStorage and NSURLCredentialStorage objects.
        let task = URLSession.shared.dataTask(with: url as URL) { (responseData, responseUrl, error) -> Void in
            // if responseData is not null...
            if let data = responseData{
                
                // execute in UI thread
                DispatchQueue.main.async {
                    view.image = UIImage(data: data)
                }
            }
        }
        
        // Run task
        task.resume()
    }

    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func longPress(sender: UILongPressGestureRecognizer) {
        
        let p: CGPoint = sender.location(in: self.tableView)
        let indexPath: IndexPath = self.tableView.indexPathForRow(at: p)!
        
        let alert: UIAlertController = UIAlertController(title: "Confirmar", message: "¿Seguro que deseas borrar esta excursion?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (UIAlertAction) -> Void in
            if let tv = self.tableView {
                self.con.borrar(actividad: self.actividadesArray[indexPath.row])
                self.actividadesArray.remove(at: indexPath.row)
                tv.deleteRows(at: [indexPath] , with: .fade)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil));
        
        if self.presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
    
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return actividadesFiltered.count
        }
        return actividadesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ActividadTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ActividadTableViewCell
        //Fetches the appropriate meal for the data source layout.
        var actividad = actividadesArray[indexPath.row]
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            actividad = actividadesFiltered[indexPath.row]
        }
        let urlImagen = "https://fcmdam-alextsanchez.c9users.io/clases/img/" + String(describing: actividad.id!) + ".jpeg"

        print(urlImagen)
        loadImageFromUrl(url: urlImagen, view: cell.imagen)
        
        cell.profesorLabel.text = actividad.nombre
        cell.tituloLabel.text = actividad.titulo
        cell.fechaLabel.text = actividad.fecha
        cell.horaIniLabel.text = actividad.horaIni
        cell.horaFinLabel.text = actividad.horaFin
        cell.grupoLabel.text = actividad.grupo
        cell.lugarLabel.text = actividad.lugar
        
        let holdToDelete = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        
        cell.addGestureRecognizer(holdToDelete)
        
        return cell
    }
    
    
    func filterContentForSearchText(_ searchText: String) {
        
        actividadesFiltered = actividadesArray.filter({( actividad : Actividad) -> Bool in
            
            
            return actividad.titulo!.lowercased().contains(searchText.lowercased()) || actividad.lugar!.lowercased().contains(searchText.lowercased()) || actividad.fecha!.lowercased().contains(searchText.lowercased()) || actividad.horaIni!.lowercased().contains(searchText.lowercased()) || actividad.horaFin!.lowercased().contains(searchText.lowercased()) || actividad.nombre!.lowercased().contains(searchText.lowercased()) || actividad.grupo!.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new Actividad.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let ActDetailViewController = segue.destination as? ActividadViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedActCell = sender as? ActividadTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedActCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedAct = actividadesArray[indexPath.row]
            ActDetailViewController.actividad = selectedAct
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    @IBAction func mensaje (sender: UIStoryboardSegue){
        print("he hecho algo")
        get()
    }
    
    
           
    func get() {
        var nuevoArray : [Actividad] = []

       
    DispatchQueue.global(qos: .background).async{
        let sURL: String = "https://fcmdam-alextsanchez.c9users.io/ios/actividad"
        
        let myUrl = NSURL(string: sURL)
        let request = NSMutableURLRequest(url: myUrl as! URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            (data,response,error) -> Void in
            
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            
            
            
            let json = JSON(data: data!)
            let coleccion = json.arrayValue
            
            for actividad in coleccion{
                let id = actividad["id"].intValue
                let nombre = actividad["nombre"].stringValue
                let idp = actividad["idp"].intValue
                let titulo = actividad["titulo"].stringValue
                let descripcion = actividad["descripcion"].stringValue
                let grupo = actividad["grupo"].stringValue
                let lugar = actividad["lugar"].stringValue
                
                let fecha = actividad["fecha"]["date"].stringValue
                let horaIni = actividad["horaIni"]["date"].stringValue
                let horaFin = actividad["horaFin"]["date"].stringValue
                
                
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let fec = format.date(from: fecha)
                let horaI = format.date(from: horaIni)
                let horaF = format.date(from: horaFin)
                
                let calendar = Calendar.current
                
                var stringMinI: String
                var stringMinF: String
                if calendar.component(.minute, from: horaI!) < 10 {
                 stringMinI = "0" + String(calendar.component(.minute, from: horaI!))
                
                } else {
                 stringMinI = String(calendar.component(.minute, from: horaI!))
                }
                
                if calendar.component(.minute, from: horaF!) < 10 {
                    stringMinF = "0" + String(calendar.component(.minute, from: horaF!))
                    
                } else {
                stringMinF = String(calendar.component(.minute, from: horaF!))
                }
                
                let f = String(calendar.component(.year, from: fec!)) + "/" + String(calendar.component(.month, from: fec!)) + "/" +  String(calendar.component(.day, from: fec!))
                
                let hI = String(calendar.component(.hour, from: horaI!)) + ":" +  stringMinI
                let hF = String(calendar.component(.hour, from: horaF!)) + ":" + stringMinF
                
                let act = Actividad(id: id,nombre: nombre, idp: idp, titulo: titulo, descripcion: descripcion, grupo: grupo, lugar: lugar, fecha: String(describing: f), horaIni: "\(hI)", horaFin: "\(hF)")
                
                nuevoArray.append(act)
                
                           }
            self.actividadesArray = nuevoArray
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                
            }

            
        }
        task.resume()
        
       
        }
    }
    
    
    @IBAction func searchButtonClick(_ sender: Any) {
        
        
        DatePickerDialog().show("Fecha", doneButtonTitle: "Aceptar", cancelButtonTitle: "Cancelar", datePickerMode: .date) {
            (date) -> Void in
            if (date != nil){
                
                
                DispatchQueue.global(qos: .background).async{
                    
                    
                    let format = DateFormatter()
                    format.dateFormat = "yyyy-MM-dd"
                    let fecha = format.string(from: date!)
                    
                    let sURL: String = "https://fcmdam-alextsanchez.c9users.io/ios/actividad/fecha/"+fecha


                    
                    print(sURL)
                    let myUrl = NSURL(string: sURL)
                    let request = NSMutableURLRequest(url: myUrl as! URL)
                    request.httpMethod = "GET"
                    let task = URLSession.shared.dataTask(with: request as URLRequest){
                        (data,response,error) -> Void in
                        
                        if error != nil{
                            print(error!.localizedDescription)
                            return
                        }
                        
                        let json = JSON(data: data!)
                        let coleccion = json.arrayValue
                        self.actividadesArray.removeAll()
                        for actividad in coleccion{
                            let id = actividad["id"].intValue
                            let nombre = actividad["nombre"].stringValue
                            let idp = actividad["idp"].intValue
                            let titulo = actividad["titulo"].stringValue
                            let descripcion = actividad["descripcion"].stringValue
                            let grupo = actividad["grupo"].stringValue
                            let lugar = actividad["lugar"].stringValue
                            
                            let fecha = actividad["fecha"]["date"].stringValue
                            let horaIni = actividad["horaIni"]["date"].stringValue
                            let horaFin = actividad["horaFin"]["date"].stringValue
                            
                            print(titulo)
                            
                            let format = DateFormatter()
                            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            
                            let fec = format.date(from: fecha)
                            let horaI = format.date(from: horaIni)
                            let horaF = format.date(from: horaFin)
                            
                            let calendar = Calendar.current
                            
                            let f =  String(calendar.component(.day, from: fec!)) + "/" + String(calendar.component(.month, from: fec!)) + "/" + String(calendar.component(.year, from: fec!))
                            
                            let hI = String(calendar.component(.hour, from: horaI!)) + ":" + String(calendar.component(.minute, from: horaI!))
                            let hF = String(calendar.component(.hour, from: horaF!)) + ":" + String(calendar.component(.minute, from: horaF!))
                            
                            
                            
                            let act = Actividad(id: id,nombre: nombre, idp: idp, titulo: titulo, descripcion: descripcion, grupo: grupo, lugar: lugar, fecha: String(describing: f), horaIni: "\(hI)", horaFin: "\(hF)")
                            
                            
                            print(act)
                            self.actividadesArray += [act]
                            
                            print(self.actividadesArray)
                            DispatchQueue.main.async {
                                
                                self.tableView.reloadData()
                                
                            }
                            
                        }
                    }
                    task.resume()
                }
                
                
            }
        }
    }

    func refresh(sender: AnyObject){
        get()
           }
    
}

extension ActividadesTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension ActividadesTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
}

public func <(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b as Date) == ComparisonResult.orderedAscending
}

public func ==(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b as Date) == ComparisonResult.orderedSame
}

extension NSDate: Comparable { }
