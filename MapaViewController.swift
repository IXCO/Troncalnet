//
//  MapaViewController.swift
//  Troncalnet
//
//  Created by Ana Arellano on 04/02/15.
//  Copyright (c) 2015 IXCO. All rights reserved.
//

import UIKit
import MapKit

class MapaViewController: UIViewController {
    var automoviles: Dictionary<String,Dictionary<String,Dictionary<String,String>>>!
    var user:Usuario!
    var auto:Auto!
    var enFavorito:Bool=false
    var timer = NSTimer()
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var btnCambiarEstilo: UIButton!
    
    @IBAction func cambiarTipoMapa(sender: AnyObject) {
        
            if mapView.mapType == MKMapType.Standard {
                self.mapView.mapType = MKMapType.Satellite
                self.btnCambiarEstilo.setTitle("Estandar", forState: UIControlState.Normal)
            } else {
                self.mapView.mapType = MKMapType.Standard
                self.btnCambiarEstilo.setTitle("Satelite", forState: UIControlState.Normal)
            }
        
    }
    @IBAction func verFavorito(sender: AnyObject) {
        //Revisa si ya se presiono antes el boton de ver favorito
        if(enFavorito == false){
            let urlBase=Direccion()
            let urlPath = urlBase.direccion+"obtenerFavorito.php?idu="+self.user.IdCliente
        var connection:Bool=false
        var existe:Bool=false
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error == nil) {
                var err: NSError?
                
                var jsonResult : AnyObject?
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                } catch let error as NSError {
                    err = error
                    jsonResult = nil
                } catch {
                    fatalError()
                }
                if(err != nil) {
                    
                    print("JSON Error \(err!.localizedDescription)")
                }
               //Realiza mapeo de petición a un diccionario
                if let topApps = jsonResult as? NSDictionary   {
                    if let feed = topApps["Favorito"] as? NSDictionary {
                        if let _=feed["placas"] as? NSString{
                            //Crea un objeto auto para integrar los datos
                            self.auto = Auto(placas: feed["placas"] as! String, id: String(feed["identificador"] as! Int), longitud: String(feed["longitud"] as! Double), latitud: String(feed["latitud"] as! Double))
                            existe=true
                            
                            
                        }
                    }
                }
                
                connection=true
            }
            dispatch_async(dispatch_get_main_queue(), {
                //Limpia el mapa de las anotaciones
                
                    for _annotation in self.mapView.annotations  {
                        if let annotation = _annotation as? MKAnnotation
                        {
                            self.mapView.removeAnnotation(annotation)
                        }
                    }
                
                var lat: NSString
                var lon: NSString
                //Centra el mapa en México
                let mexico = CLLocationCoordinate2D(latitude: 23.6260333, longitude: -102.5375005)

                
                let span = MKCoordinateSpanMake(25.0, 14.0)
                let region = MKCoordinateRegion(center: mexico, span: span)
                self.mapView.setRegion(region, animated: true)
                //Si no hubo problema en la conexión y hay un auto favorito marca la anotación
                if((connection == true) && (existe == true)){
                   
                            //Crea anotación del auto favorito
                            lat = self.auto.latitud
                            lon = self.auto.longitud
                            let location = CLLocationCoordinate2D( latitude: lat.doubleValue, longitude: lon.doubleValue)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate=location
                            
                            annotation.title = self.auto.id
                            annotation.subtitle = "Placas: " + self.auto.placas
                            self.mapView.addAnnotation(annotation)
                    self.enFavorito = true

                    
                }else if(existe == false){ //Si no existe un auto favorito asociado al numero de cliente marca error
                    let alertController = UIAlertController(title: "Aviso", message:
                        "No existe auto favorito en esta cuenta.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    //Volver a presentar todos los autos
                    self.cargarDatos()
                    

                }
                else{//Si hubo problemas en la conexión
                    let alertController = UIAlertController(title: "Error", message:
                        "No se pudo conectar. Vuelva a intentar en unos minutos o revise su conexión a internet.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
            
            
            
            
            
        })
        task.resume()
        }else{
            cargarDatos()
            enFavorito = false
        }
        //Cambia el estatus de presionado o no
        

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cargarDatos()
        //Cada 3 segundos carga denuevo los datos
        timer = NSTimer.scheduledTimerWithTimeInterval(300, target:self, selector: Selector("cargarDatos"), userInfo: nil, repeats: true)

        
        
    }
   
    func cargarDatos(){
        
        let urlPath = "http://200.94.45.124/TI/autos.php?idu="+self.user.IdUsuario+"&idc="+self.user.IdCliente
        
        var _ : String? = nil
        var connection:Bool=false
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error == nil) {
                var err: NSError?

                var jsonResult : AnyObject?
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                } catch let error as NSError {
                    err = error
                    jsonResult = nil
                } catch {
                    fatalError()
                }
                if(err != nil) {
                    
                    print("JSON Error \(err!.localizedDescription)")
                }
                //Obtiene el resultado en un diccionario previamente declarado
                if let _ = jsonResult as? NSDictionary   {
                    
                    self.automoviles = jsonResult as? Dictionary
                }
                
                connection=true
            }
                dispatch_async(dispatch_get_main_queue(), {
                    var _ : Dictionary<String,Dictionary<String,String>>
                    var auto :Dictionary<String,String>
                    var lat: NSString
                    var lon: NSString
                    let mexico = CLLocationCoordinate2D(latitude: 23.6260333, longitude: -102.5375005)
                    
                    let span = MKCoordinateSpanMake(25.0, 14.0)
                    let region = MKCoordinateRegion(center: mexico, span: span)
                    self.mapView.setRegion(region, animated: true)
                    //Si se obtuvo información
                    if(connection == true){
                        //Por cada estructuctura de auto
                        for value in self.automoviles.values{
                            //Busca cada atributo del auto
                            for valor in value.values{
                                //Mapea los valores a las variables para generar una anotación por cada auto
                                auto = valor as Dictionary
                                lat = auto["latitude"] as NSString!
                                lon = auto["longitude"] as NSString!
                                let location = CLLocationCoordinate2D( latitude: lat.doubleValue, longitude: lon.doubleValue)
                                let annotation = MKPointAnnotation()
                                annotation.coordinate=location
                                
                                annotation.title = auto["modelo"] as String!
                                annotation.subtitle = "Placas: " + auto["placas"]! as String!
                                self.mapView.addAnnotation(annotation)
                                
                                
                            }
                            
                        }
                    }else{
                        let alertController = UIAlertController(title: "Error", message:
                            "No se pudo conectar. Vuelva a intentar en unos minutos o revise su conexión a internet.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                })
                
            
            
            
    
        })
        task.resume()

    
}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}