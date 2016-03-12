//
//  Usuario.swift
//  Troncalnet
//
//  Created by Ana Arellano on 11/9/15.
//  Copyright © 2015 IXCO. All rights reserved.
//

import Foundation
class Usuario{
    var IdCliente: String!
    var IdUsuario : String!
    init(idCliente:String,idusuario:String){
        self.IdCliente=idCliente
        self.IdUsuario = idusuario
    }
}