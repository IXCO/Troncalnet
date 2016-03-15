//
//  HistorialViewController.swift
//  Troncalnet
//
//  Created by Ana Arellano on 11/3/15.
//  Copyright © 2015 IXCO. All rights reserved.
//

import UIKit

class HistorialViewController: UIViewController {
    var auto:Auto!
    var periodosPosibles=["1 Semana"]
    var periodoSeleccionado:Int = 0
    var dias:String!
    
   
    @IBOutlet weak var periodo: UIPickerView!
    
    @IBOutlet weak var direccionRecibe: UITextField!
    @IBAction func enviar(sender: AnyObject) {
        
    
        if ((direccionRecibe.text != "") && (isValidEmail(direccionRecibe.text!))){
        switch(periodoSeleccionado){
        case 0:
            dias="7"
            break;
        case 1:
            dias="15"
            break;
        case 3:
            dias="30"
            break;
        default:
            dias="7"
            }
           enviarCorreo()
        }else{
            crearMensaje("Error", mensaje: "Debe ingresar una dirección de correo electronico valida.", boton: "Aceptar")
        }
        
            }
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluateWithObject(testStr)
        
        return result
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func crearMensaje(titulo:String,mensaje:String,boton:String){
        let alertController = UIAlertController(title: titulo, message:
            mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: boton, style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func enviarCorreo(){
        var resultado: Dictionary<String,Dictionary<String,String>>!
        var connection:Bool=false
        let urlBase=Direccion()
        let urlPath = urlBase.direccion+"reporteAnterior.php?idv="+String(self.auto.id)+"&periodo="+self.dias+"&correo="+self.direccionRecibe.text!
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error == nil) {
                //Revisa por posibles errores de respuesta
                var jsonResult : AnyObject?
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData((data)!, options: NSJSONReadingOptions.MutableContainers)
                }catch {
                    jsonResult = nil
                    fatalError()
                }
                //Mapea el JSON a un diccionario
                if let _ = jsonResult as? NSDictionary   {
                    
                    resultado = jsonResult as? Dictionary
                }
                connection = true
            }
            dispatch_async(dispatch_get_main_queue(), {

                if(connection == true){
                    var exito=""
                    let respuesta=resultado["Resultado"]
                    for valor in (respuesta?.values)!{
                        exito=valor
                    }
                    if exito == "Exito"{
                        self.crearMensaje("Exito", mensaje: "Correo enviado exitosamente.", boton: "Aceptar")
                    }else{
                        self.crearMensaje("Error", mensaje: "No se pudo enviar el correo. Intente más tarde.", boton: "Aceptar")
                    }
                    
                }else {
                    //Si no hay conexión avisa al usuario para que vuelva a intentar
                    self.crearMensaje("Error", mensaje: "No se pudo conectar. Vuelva a intentar en unos minutos o revise su conexión a internet.", boton: "Aceptar")
                    
                    
                }
               
            })
            
        })
        task.resume()
        
    }

    //MARK: - PickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return periodosPosibles.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return periodosPosibles[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        periodoSeleccionado = row
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
