//
//  AutomovilesTableViewController.swift
//  Troncalnet
//
//  Created by Ana Arellano on 3/6/15.
//  Copyright (c) 2015 IXCO. All rights reserved.
//

import UIKit

class AutomovilesTableViewController: UITableViewController {
    var automoviles : Dictionary<String,Dictionary<String,Dictionary<String,String>>>!
    var autos=[Auto]()
    var user:Usuario!
    var autoFavorito:Auto!
    var autoEscogido:Auto!
    @IBAction func regresarTabla(segue: UIStoryboardSegue){
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.cargarFavorito()
        self.cargarAutos()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func cargarFavorito(){
        let urlBase=Direccion()
        let urlPath = urlBase.direccion+"obtenerFavorito.php?idu="+self.user.IdCliente
        /*var connection:Bool=false
        var existe:Bool=false*/
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
        
            if(error == nil) {
                var jsonResult : AnyObject?
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                }  catch {
                    fatalError()
                }
               
                //Realiza mapeo de petición a un diccionario
                if let topApps = jsonResult as? NSDictionary   {
                    if let feed = topApps["Favorito"] as? NSDictionary {
                        if let _=feed["placas"] as? NSString{
                            //Crea un objeto auto para integrar los datos
                            self.autoFavorito = Auto(placas: feed["placas"] as! String, id: String(feed["identificador"] as! Int), longitud: String(feed["longitud"] as! Double), latitud: String(feed["latitud"] as! Double))
                            //existe=true
                            
                        }
                    }
                }
                
                //connection=true
            }
            /*dispatch_async(dispatch_get_main_queue(), {
              
                if((connection == false) && (existe == false)){//Si hubo problemas en la conexión
                    let alertController = UIAlertController(title: "Error", message:
                        "No se pudo conectar. Vuelva a intentar en unos minutos o revise su conexión a internet.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })*/
            
        })
        task.resume()

        
    }
    func cargarAutos(){
        var connection:Bool=false
        let urlBase=Direccion()
        let urlPath = urlBase.direccion+"autos.php?idu="+self.user.IdUsuario+"&idc="+self.user.IdCliente
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error == nil) {
                
                var jsonResult : AnyObject?
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData((data)!, options: NSJSONReadingOptions.MutableContainers)
                } catch _ as NSError {
                    
                    jsonResult = nil
                } catch {
                    fatalError()
                }
                
                if let _ = jsonResult as? NSDictionary   {
                    
                    self.automoviles = jsonResult as? Dictionary
                }
                connection = true
            }
            dispatch_async(dispatch_get_main_queue(), {
                var _ : Dictionary<String,Dictionary<String,String>>
                var arreglo :Dictionary<String,String>
                if(connection == true){
                    
                    for value in self.automoviles.values{
                        for valor in value.values{
                            arreglo = valor as Dictionary
                            let autoTemporal = Auto(placas: arreglo["placas"] as String!, modelo: arreglo["modelo"] as String!, id: arreglo["id"] as String!)
                            self.autos.append(autoTemporal)
                            
                            
                        }
                        
                    }
                    let vacio = Auto(placas: "", modelo: "", id: "")
                    self.autos.append(vacio)
                    //Recarga los datos de la tabla con los autos encontrado
                    self.tableView.reloadData()
                }else {
                    let alertController = UIAlertController(title: "Error", message:
                        "No se pudo conectar. Vuelva a intentar en unos minutos o revise su conexión a internet.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
            })
            
        })
        task.resume()
   
    }
    func marcarComoFavorito(indice: Int){
        var connection:Bool=false
        let urlBase=Direccion()
        let urlPath = urlBase.direccion+"insertarFavorito.php?idu="+self.user.IdCliente+"&idv="+self.autos[indice].id
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error == nil) {
                connection = true
            }
            dispatch_async(dispatch_get_main_queue(), {
                
                if(connection == true){
                    self.autoFavorito = nil
                    self.autos.removeAll()
                    self.cargarFavorito()
                    self.cargarAutos()
                    self.tableView.reloadData()
                  
                }else {
                    let alertController = UIAlertController(title: "Error", message:
                        "No se pudo conectar. Vuelva a intentar en unos minutos o revise su conexión a internet.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
            })
            
        })
        task.resume()

    
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        if autos.isEmpty {
            return 0
        }else{
        return self.autos.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        let modelo = self.autos[indexPath.row].modelo
        let placas = " Placas:" + self.autos[indexPath.row].placas
        let texto = modelo
        cell.textLabel?.text=texto
        cell.textLabel?.textColor=UIColor(red: 0, green: (112.0/255.0), blue: (51.0/255.0), alpha: 1.0)
        cell.detailTextLabel?.text=placas
        cell.backgroundColor=UIColor.whiteColor()
        if(self.autoFavorito != nil){
        if(self.autos[indexPath.row].placas == self.autoFavorito.placas){
            cell.accessoryType = .Checkmark
        }else{
            cell.accessoryType = .None
        }
        }else{
            cell.accessoryType = .None
        }
        tableView.tableFooterView = UIView(frame:CGRectZero)
        tableView.separatorColor=UIColor(red: 0, green: (112.0/255.0), blue: (51.0/255.0), alpha: 1.0)
        
        

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.autoEscogido = self.autos[indexPath.row]
        self.performSegueWithIdentifier("historial", sender: self)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
            
            let favorite = UITableViewRowAction(style: .Normal, title: "Favorito") { action, index in
                
                //self.marcarComoFavorito(indexPath.row)
                print(self.autos[indexPath.row].modelo)
                let alertController = UIAlertController(title: "Confirmación", message:
                    "¿Desea marcar este auto como su favorito?", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: {
                    (action:UIAlertAction!) in
                    self.marcarComoFavorito(indexPath.row)
                }))
                alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            favorite.backgroundColor = UIColor.orangeColor()
        
            
            return [favorite]
        
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "historial") {
            let controladorRegistro = segue.destinationViewController as! RegistroViewController
            controladorRegistro.autoid = self.autoEscogido
            controladorRegistro.user = self.user
        }
        
    }


}
