//
//  MainViewController.swift
//  Troncalnet
//
//  Created by Ana Arellano on 30/01/15.
//  Copyright (c) 2015 IXCO. All rights reserved.
//

import UIKit

class MainViewController: UIViewController,UITextFieldDelegate {
    @IBAction func regresarInicio(segue: UIStoryboardSegue){
        
    }
    var user:Usuario!
    
    @IBOutlet weak var username: UITextField!

    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //funcion para el evento de tocar el boton
    @IBAction func ingresar(sender: UIButton) {
        accesa()
    }
    func crearMensaje(titulo:String,mensaje:String,boton:String){
        let alertController = UIAlertController(title: titulo, message:
            mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: boton, style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func accesa(){
        let usuario:String! = self.username.text
        let contra:String! = self.password.text
        if( usuario != "" && contra != "" ){
                let urlBase=Direccion()
                let urlPath = urlBase.direccion+"valid.php?username="+usuario+"&password="+contra
                        
                var result : String? = nil
                let url = NSURL(string: urlPath)
                var connection:Bool=false
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                    var err: NSError?
                    var jsonResult : AnyObject?
                    if(error == nil){
                            do {
                                jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            } catch let error as NSError {
                                err = error
                                jsonResult = nil
                            } catch {
                                fatalError()
                            }
                            if(err != nil) {
                            }
                            
                            if let topApps = jsonResult as? NSDictionary   {
                                if let feed = topApps["User"] as? NSDictionary {
                                    if let intern=feed["name"] as? NSString{
                                        result=intern as String
                                        
                                        let clin = feed["clientID"] as! Int
                                        
                                        let udc = feed["userID"] as! Int
                                        
                                        self.user = Usuario(idCliente: String(clin), idusuario: String(udc))
                                    }
                                    
                                }
                            }
                            connection=true
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                                if (result != nil ){
                                    //sin error
                                    self.performSegueWithIdentifier("menu", sender: self)
                                }else if(result == nil && err == nil && connection==true){
                                    //error de parametros
                                    self.crearMensaje("Error", mensaje: "Usuario y/o contraseña incorrecto", boton: "Aceptar")
                                     }else{
                                    self.crearMensaje("Error", mensaje: "No se pudo conectar, vuelva a intentar en unos momentos o revise su conexión.", boton: "Aceptar")                                }
                                
                            })
                    
                    
                        })
                        
                task.resume()
            }else{
            //datos vacios
            crearMensaje("Error", mensaje: "Debe ingresar sus datos para acceder a su cuenta.", boton: "Aceptar")
            }

    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tab = segue.destinationViewController as! UITabBarController
        let svc = tab.viewControllers?.first as! MapaViewController
        svc.user = self.user
       
        let controllers = tab.viewControllers?.dropLast(1)
        let scnd = controllers?.last as! AutomovilesTableViewController
        scnd.user = self.user
      
        let controller = tab.viewControllers?.dropFirst(2)
        let notificaciones = controller?.first as! NotificacionesTableViewController
        notificaciones.user = self.user
        
        
    }
    /* Mark-TextField
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        
            if textField == self.username {
                self.password.becomeFirstResponder()
            }else{
                accesa()
            }

        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    }

