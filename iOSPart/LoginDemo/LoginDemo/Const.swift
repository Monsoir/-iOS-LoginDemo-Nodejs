//
//  Const.swift
//  LoginDemo
//
//  Created by Mon on 31/08/2017.
//  Copyright © 2017 monwingyeung. All rights reserved.
//

import Foundation

let IPAddress = "127.0.0.1"
let Port = "8080"
let RequestAddress = "http://\(IPAddress):\(Port)"
let TokenKey = "token"

let AccessTokenAddress = "\(RequestAddress)/api/user/accesstoken"
let UserInfoAddress = "\(RequestAddress)/api/user/info"
let RegisterAddress = "\(RequestAddress)/api/signup"
