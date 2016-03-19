
//
//  Settings.swift
//  Octo Print
//
//  Created by William Young on 3/10/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit

class settings: NSObject, NSCoding {
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveUrl = DocumentsDirectory.URLByAppendingPathComponent("settings")
    
    static var currentSettings:settings? = settings().loadSettings()
    
    static func reloadSettings() -> settings {
        currentSettings = settings().loadSettings()
        if currentSettings == nil {
            currentSettings = settings()
            currentSettings?.saveSettings()
        }
        return currentSettings!
    }
    
    var url:String?
    var apikey:String?
    var tempPresets:[String:TemperaturePreset]?
    
    func saveSettings(){
        NSKeyedArchiver.archiveRootObject(self, toFile: settings.ArchiveUrl.path!)
    }
    
    func loadSettings() -> settings? {
        if let load = NSKeyedUnarchiver.unarchiveObjectWithFile(settings.ArchiveUrl.path!) {
            return load as? settings
        }
        return nil
    }
    
    struct PropertyKey {
        static let url = "url"
        static let apikey = "apikey"
        static let temps = "tempPresets"
    }
    
   
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(url,forKey: PropertyKey.url)
        aCoder.encodeObject(apikey, forKey: PropertyKey.apikey)
        aCoder.encodeObject(tempPresets, forKey: PropertyKey.temps)
    }
    
    required init?(coder aDecoder: NSCoder) {
        url = aDecoder.decodeObjectForKey(PropertyKey.url) as? String
        apikey = aDecoder.decodeObjectForKey(PropertyKey.apikey) as? String
        tempPresets = aDecoder.decodeObjectForKey(PropertyKey.temps) as? [String:TemperaturePreset]
    }
    
    override init(){
        
    }
    
}

class TemperaturePreset:NSObject, NSCoding {
    
    let name:String
    let hotEnd:[Int]
    let bed:Int
    
    init(name:String, hotEnd:[Int], bed:Int) {
        self.name = name
        self.hotEnd = hotEnd
        self.bed = bed
        super.init()
    }
    
    struct PropertyKey {
        static let name = "name"
        static let hotend = "hotend"
        static let bed = "bed"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.name)
        aCoder.encodeObject(hotEnd, forKey: PropertyKey.hotend)
        aCoder.encodeInteger(bed, forKey: PropertyKey.bed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(PropertyKey.name) as! String
        hotEnd = aDecoder.decodeObjectForKey(PropertyKey.hotend) as! [Int]
        bed = aDecoder.decodeIntegerForKey(PropertyKey.bed)
        super.init()
    }
    
}
