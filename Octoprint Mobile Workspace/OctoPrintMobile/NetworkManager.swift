//
//  NetworkManager.swift
//  Octo Print
//
//  Created by William Young on 3/10/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {

    static var currentManager:NetworkManager = NetworkManager()
    
    static func reload() -> NetworkManager {
        
        currentManager.cleanup()
        
        currentManager = NetworkManager()
        
        return currentManager
    }
    
    let apiKeyName = "X-Api-Key"
    let contentType = "Content-Type"
    let appJson = "application/json"
    
    var url:String
    var apikey:String
    
    init(){
        let setting = settings.reloadSettings()
        if let setUrl = setting.url {
            url = setUrl
        } else {
            url = "localhost"
        }
        
        if let setKey = setting.apikey {
            apikey = setKey
        } else {
            apikey = ""
        }
        
    }
    
    func cleanup(){
        
    }
    
    func getStatus(closure:() -> Void = {}){
        Alamofire.request(.GET , url + "/api/job", headers:[apiKeyName:apikey,contentType:appJson],encoding: .JSON).responseString(completionHandler: {_ in
            closure()
        })
    }
    
    func startPrint(file:String, closure:() -> Void = {}){
        doSelect(file, doPrint: true, closure: closure)
    }
    
    func doSelect(file:String, doPrint:Bool = true , closure:() -> Void = {}){
        Alamofire.request(.POST, file, headers:[apiKeyName:apikey,contentType:appJson], parameters:["command":"select","print":doPrint], encoding: .JSON).responseString(completionHandler: {
            response in
            print(response)
            closure()
        })
    }
    
    func doUpload(file:NSURL, location:String = "local", closure:() -> Void = {}, cleanup:() -> Void = {}, progress:(Float) -> Void = {_ in }, error:(ErrorType) -> Void = {_ in} ){
        let name = file.lastPathComponent
        print(name)
        let manager = Manager.sharedInstance
        
        manager.upload(.POST, url + "/api/files/" + location /* */ ,headers: [apiKeyName:apikey],
            multipartFormData: {
            multiportFormData in
            multiportFormData.appendBodyPart(fileURL: file, name:"file")
            },encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.progress({
                        _, totalBytesRead, BytesToRead in
                        let percent = Float(totalBytesRead)/Float(BytesToRead)
                        progress(percent)
                    })
                    upload.responseJSON(completionHandler: {
                        response in
                        closure()
                        cleanup()
                    })
                case .Failure(let encodingError):
                    error(encodingError)
                    cleanup()
                }
        })
        
    }
    
    func doDelete(file:String, closure: () -> Void = {}){
        Alamofire.request(.DELETE, file, headers:[apiKeyName:apikey,contentType:appJson]).responseString(completionHandler: {
            response in
            closure()
            })
    }
    
    func doConnect(port:String, baudrate:Int, printerProfile:String, save:Bool = false, autoconnect:Bool = false,closure: () -> Void = {}){
        let parameters:[String:AnyObject] = ["command":"connect","port":port,"baudrate":baudrate,"printerProfile":printerProfile, "save":save, "autoconnect":autoconnect]
        print(parameters)
        Alamofire.request(.POST, url + "/api/connection", headers:[apiKeyName:apikey,contentType:appJson],parameters:parameters,encoding: .JSON).responseString(completionHandler: {_ in
            closure()
        })
    }
    
    func doDisconnect(closure: () -> Void = {}){
        Alamofire.request(.POST, url + "/api/connection", headers:[apiKeyName:apikey,contentType:appJson],parameters:["command":"disconnect"],encoding: .JSON).responseString(completionHandler: {_ in
                closure()
        })
    }
    
    func getConnection(closure: ([String:JSON]) -> Void){
        Alamofire.request(.GET, url + "/api/connection", headers:[apiKeyName:apikey,contentType:appJson], encoding: .JSON).responseString(completionHandler: {
            Response in
            if let data = Response.result.value?.dataUsingEncoding(NSUTF8StringEncoding) {
                let json = JSON(data:data)
                if let connection = json.dictionary {
                    closure(connection)
                }
            }
        })
    }
    
    func getFileListing(closure: ([String:JSON]) -> Void){
        Alamofire.request(.GET, url + "/api/files", headers:[apiKeyName:apikey,contentType:appJson], encoding: .JSON).responseString(completionHandler: {
            Response in
            if let data = Response.result.value?.dataUsingEncoding(NSUTF8StringEncoding) {
                let json = JSON(data:data)
                if let files = json.dictionary {
                    closure(files)
                }
            }
        })
    }
    
    func setBedTemp(temp:Int,closure: () -> Void = {}){
        Alamofire.request(.POST, url + "/api/printer/bed", headers:[apiKeyName:apikey,contentType:appJson], parameters:["command":"target","target":temp], encoding: .JSON).responseString(completionHandler: {_ in
            closure()
        })
    }
    
    func setToolTemp(tool:String, temp:Int, closure:() -> Void = {}) {
        
        Alamofire.request(.POST, url + "/api/printer/tool", headers:[apiKeyName:apikey,contentType:appJson], parameters:["command":"target","targets":[tool:temp]], encoding: .JSON).responseString(completionHandler: {_ in
            closure()
        })
        
    }
    
    func extrudeAmount(amount:Int, closure:() -> Void = {}) {
        
        Alamofire.request(.POST, url + "/api/printer/tool", headers:[apiKeyName:apikey,contentType:appJson], parameters:["command":"extrude","amount":amount], encoding: .JSON).responseString(completionHandler: {_ in
            closure()
        })
        
    }

    
    func homeAxes(x:Bool = false, y:Bool = false, z:Bool = false, closure:() -> Void = {}) {
        
        var axes:[String] = []
        
        if x {
            axes.append("x")
        }
        if y {
            axes.append("y")
        }
        if z {
            axes.append("z")
        }
        
        Alamofire.request(.POST, url + "/api/printer/printhead", headers:[apiKeyName:apikey,contentType:appJson], parameters:["command":"home","axes":axes], encoding: .JSON).responseString(completionHandler: {_ in
            closure()
        })
        
    }
    
    func sendJog(scale:Int = 1, x:Int = 0, y:Int = 0, z:Int = 0, closure:() -> Void = {}) {
        
        Alamofire.request(.POST, url + "/api/printer/printhead", headers:[apiKeyName:apikey,contentType:appJson], parameters:["command":"jog","x":x*scale,"y":y*scale,"z":z*scale], encoding: .JSON).responseString(completionHandler: {_ in
            closure()
        })
        
    }
    
    func getTemperatures(closure : ([String : JSON]) -> Void ) {
        Alamofire.request(.GET, url + "/api/printer?exclude=sd,state", headers:[apiKeyName:apikey,contentType:appJson]).responseString{
            Response in
            if let data = Response.result.value?.dataUsingEncoding(NSUTF8StringEncoding) {
                let json = JSON(data:data)
                if let hotend = json["temperature"].dictionary {
                    closure(hotend)
                }
            }
        }
    }
    
    func getVersion(closure : (String) -> Void) {
                
        Alamofire.request(.GET, url + "/api/version",headers: [apiKeyName:apikey,contentType:appJson]).responseString{
            Response in
            if let data = Response.result.value?.dataUsingEncoding(NSUTF8StringEncoding) {
                let json = JSON(data:data)
                if let version = json["server"].string {
                    closure(version)
                }
            }
        }
    }
    
}