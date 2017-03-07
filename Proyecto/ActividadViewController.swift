//
//  ActividadViewController.swift
//  Proyecto
//
//  Created by dam on 31/1/17.
//  Copyright © 2017 dam. All rights reserved.
//

import os.log
import UIKit

class ActividadViewController: UIViewController, UITextViewDelegate, NSURLConnectionDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    

    //MARK: Componentes
    
    @IBOutlet weak var imagen: UIImageView!
    //Navigation Bar

    @IBOutlet weak var aceptar: UIBarButtonItem!
    
    //Formulario
    @IBOutlet weak var tituloField: UITextField!
    
    @IBOutlet weak var profesoresField: UIPickerView!

    @IBOutlet weak var descripcionField: UITextView!
    
    @IBOutlet weak var grupoField: UIPickerView!
    
    @IBOutlet weak var lugarField: UITextField!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var fechaField: UIDatePicker!
    
    @IBOutlet weak var horaIniField: UIDatePicker!
    
    @IBOutlet weak var horaFinField: UIDatePicker!
    
    
    //Variables-Constantes
    let urlStr = "https://fcmdam-alextsanchez.c9users.io/ios/profesor"
    
    var fecha: String = ""
    var horaIni: String = ""
    var horaFin: String = ""
  
    var actividad: Actividad?

    var profesoresArray: [String] = []
    var idArray: [Int] = []
    
    let gruposArray = ["A", "B", "C", "D"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getProfesores()
        profesoresField.dataSource = self
        profesoresField.delegate = self
        
        
        self.grupoField.dataSource = self
        self.grupoField.delegate = self
        
        if let actividad = actividad {
            tituloField.text = actividad.titulo
            descripcionField.text = actividad.descripcion
           
            lugarField.text = actividad.lugar
            
            
            //Set fecha y hora
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            
            let horaFormatter = DateFormatter()
            horaFormatter.dateFormat = "HH:mm"
            
            let fechaConvert = dateFormatter.date(from: actividad.fecha!)
            self.fechaField.date = fechaConvert!
            
            let horaIniConvert = horaFormatter.date(from: actividad.horaIni!)
            self.horaIniField.date = horaIniConvert!
            
            let horaFinConvert = horaFormatter.date(from: actividad.horaFin!)
            self.horaFinField.date = horaFinConvert!
            
            //Set Grupo
            let grupo = actividad.grupo
            let index = gruposArray.index(of: grupo!)
            grupoField.selectRow(index!, inComponent: 0, animated: true)
            
            let urlImagen = "https://fcmdam-alextsanchez.c9users.io/clases/img/" + String(describing: actividad.id!) + ".jpeg"
            print(urlImagen)
            loadImageFromUrl(url: urlImagen, view: imagen)
            
        }

    }
 
   
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        
        // Hide the keyboard.
        tituloField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }

   
    //MARK: get
    func getProfesores() {
        DispatchQueue.global(qos: .background).async{
            let sURL: String = self.urlStr
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
                DispatchQueue.main.async {
                    for profesor in coleccion{
                        let nombre = profesor["nombre"].stringValue
                        let id = profesor["id"].intValue
                     
                        self.idArray += [id]
                        self.profesoresArray += [nombre]
                     
               }
                    self.profesoresField.dataSource = self
                    self.profesoresField.delegate = self
                }
            }
            task.resume()
        }
    }

    
    // MARK: - Navigation
    
    
    
    @IBAction func cancelarAction(_ sender: UIBarButtonItem) {
        
        let isPresentingInAddActividadMode = presentingViewController is UINavigationController
        
        if isPresentingInAddActividadMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The ActividadiewController is not inside a navigation controller.")
        }
    }
    
    func fechaFormat(f: Date, hI: Date, hF: Date) -> Array<String>{
        
        let date = self.fechaField.date
        let hI = self.horaIniField.date
        let hF = self.horaFinField.date
        let format = DateFormatter()
        
        format.dateFormat = "yyyy-MM-dd"
        let fecha = format.string(from: date)
        format.dateFormat = "HH:mm:ss"
        let horaIni = format.string(from: hI)
        let horaFin = format.string(from: hF)

        return [fecha, horaIni, horaFin]
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === aceptar else {
            if #available(iOS 10.0, *) {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
            return
        }
        
        DispatchQueue.global(qos: .background).async{
            
            if(self.actividad?.id != nil){
                
                let sURL: String = "https://fcmdam-alextsanchez.c9users.io/ios/actividad/"
                
                let myUrl = NSURL(string: sURL)
                let request = NSMutableURLRequest(url: myUrl as! URL)
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "PUT"
                
                let date = self.fechaField.date
                let hI = self.horaIniField.date
                let hF = self.horaFinField.date
                let format = DateFormatter()
                
                format.dateFormat = "yyyy-MM-dd"
                let fecha = format.string(from: date)
                format.dateFormat = "HH:mm:ss"
                let horaIni = format.string(from: hI)
                let horaFin = format.string(from: hF)
                
                let imagen = self.resizeImage(image: self.imagen.image!, targetSize: CGSize(width: 400, height: 400))
                let img = UIImageJPEGRepresentation(imagen, 75)
                let nuIm = img?.base64EncodedString()
                
                
                
                let body: [String: Any] = ["id": self.actividad!.id!, "idp": self.idArray[self.grupoField.selectedRow(inComponent: 0)],"titulo": self.tituloField.text!, "descripcion": self.descripcionField.text ?? "", "grupo": self.gruposArray[self.grupoField.selectedRow(inComponent: 0)],"fecha": fecha,"lugar": self.lugarField.text!,"horaIni": horaIni, "horaFin": horaFin, "imagen": nuIm!]
                
                
                do{
                    let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                    request.httpBody = jsonBody
                    
                    
                    
                } catch {
                    
                }
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){
                    (data,response,error) -> Void in
                    
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }
                    print("obtengo respuesta")
                }
                task.resume()
                
                
            }else{
                
                let sURL: String = "https://fcmdam-alextsanchez.c9users.io/ios/actividad/"
                let myUrl = NSURL(string: sURL)
                let request = NSMutableURLRequest(url: myUrl as! URL)
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                
                let date = self.fechaField.date
                let hI = self.horaIniField.date
                let hF = self.horaFinField.date
                let format = DateFormatter()
                
                format.dateFormat = "yyyy-MM-dd"
                let fecha = format.string(from: date)
                format.dateFormat = "HH:mm:ss"
                let horaIni = format.string(from: hI)
                let horaFin = format.string(from: hF)
                
                
                let imagen = self.resizeImage(image: self.imagen.image!, targetSize: CGSize(width: 400, height: 400))
                let img = UIImageJPEGRepresentation(imagen, 75)
                let nuIm = img?.base64EncodedString()
                
                
                
                let body: [String: Any] = ["idp": self.idArray[self.grupoField.selectedRow(inComponent: 0)],"titulo": self.tituloField.text!, "descripcion": self.descripcionField.text ?? "", "grupo": self.gruposArray[self.grupoField.selectedRow(inComponent: 0)],"fecha": fecha,"lugar": self.lugarField.text!,"horaIni": horaIni, "horaFin": horaFin, "imagen": nuIm!]
                print(body)
                
                do{
                    let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                    request.httpBody = jsonBody
                    
                    
                    
                } catch {
                    
                }
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){
                    (data,response,error) -> Void in
                    
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }
                    print("obtengo respuesta")
                }
                task.resume()
            }
        }
        print("cierro")
    }
    
    
   
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 1){
            return profesoresArray.count
        }else{
            return gruposArray.count
        }
    }
    
    // Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 1){
            return profesoresArray[row]
        }else{
            return gruposArray[row]
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
    }
    
}
