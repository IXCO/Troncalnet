//
//  Auto.swift
//  Troncalnet
//
//  Created by Ana Arellano on 11/9/15.
//  Copyright © 2015 IXCO. All rights reserved.
//

import Foundation
class Auto{
    var modelo:String!
    var placas:String!
    var id:String!
    var longitud:String!
    var latitud:String!
    init(placas :String, modelo: String, id :String){
        self.placas=placas
        self.modelo=modelo
        self.id=id
    }
    init(placas:String,id:String,longitud:String,latitud:String){
        self.placas=placas
        self.id=id
        self.longitud=longitud
        self.latitud=latitud
    }
    
}
