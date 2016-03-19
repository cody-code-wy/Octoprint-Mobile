//
//  Connection.swift
//  Octo Print
//
//  Created by William Young on 3/12/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit
import SwiftyJSON

class Connection:UIViewController {
    
    var BaudRateDS:BaudRateData?
    var SerialPortDS:SerialPortData?
    var PrinterProfileDS:PrinterProfileData?
    
    override func viewDidLoad() {
        BaudRateDS = BaudRateData(picker: BaudRate)
        SerialPortDS = SerialPortData(picker: SerialPort)
        PrinterProfileDS = PrinterProfileData(picker: PrinterProfile)
        refreshSelectors()
    }
    
    func refreshSelectors() {
        NetworkManager.currentManager.getConnection({
            json in
            let current = json["current"]
            let options = json["options"]
            
            if current?.dictionaryValue["state"] == "Operational" || current?.dictionaryValue["state"] == "Printing" {
                self.ConnectionIcon.image = UIImage(named: "Connected")
                self.ConnectionLabel.text = "Connected"
                self.ConnectButton.hidden = true
                self.DisocnnectButton.hidden = false
            } else {
                self.ConnectionIcon.image = UIImage(named: "Disconnected")
                self.ConnectionLabel.text = "Not connected"
                self.ConnectButton.hidden = false
                self.DisocnnectButton.hidden = true
            }
            
            /* Future proofing
            if (options?.dictionaryValue["autoconnect"]) != nil {
                self.Autoconnect.on = true
            } else {
                self.Autoconnect.on = false
            }*/
            
            self.BaudRateDS?.rates = options?.dictionaryValue["baudrates"]?.arrayObject as? [Int]
            self.BaudRateDS?.pref = (options?.dictionaryValue["baudratePreference"]?.intValue)!
            self.BaudRateDS?.reload()
            
            self.SerialPortDS?.ports = options?.dictionaryValue["ports"]?.arrayObject as? [String]
            self.SerialPortDS?.pref = (options?.dictionaryValue["portPreference"]?.stringValue)!
            self.SerialPortDS?.reload()
            
            self.PrinterProfileDS?.profiles = options?.dictionaryValue["printerProfiles"]?.arrayObject as? [[String:String]]
            self.PrinterProfileDS?.pref = (options?.dictionaryValue["printerProfilePreference"]?.stringValue)!
            self.PrinterProfileDS?.reload()
            
        })
    }
    
    @IBOutlet weak var ConnectionIcon: UIImageView!
    @IBOutlet weak var ConnectionLabel: UILabel!
    @IBOutlet weak var BaudRate: UIPickerView!
    @IBOutlet weak var SerialPort: UIPickerView!
    @IBOutlet weak var PrinterProfile: UIPickerView!
    @IBOutlet weak var ConnectButton: UIButton!
    @IBOutlet weak var Autoconnect: UISwitch!
    @IBOutlet weak var DisocnnectButton: UIButton!
    @IBAction func Refresh(sender: AnyObject) {
        refreshSelectors()
    }
    @IBAction func Connect(sender: AnyObject) {
        NetworkManager.currentManager.doConnect((SerialPortDS?.ports?[SerialPort.selectedRowInComponent(0)])!, baudrate: (BaudRateDS?.rates?[BaudRate.selectedRowInComponent(0) == 0 ? 0 : BaudRate.selectedRowInComponent(0)-1])!, printerProfile: (PrinterProfileDS?.profiles?[PrinterProfile.selectedRowInComponent(0)]["id"])!,save: true, closure: {
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(self.refreshSelectors), userInfo: nil, repeats: false)
            //self.refreshSelectors()
        })
    }
    @IBAction func Disconnect(sender: AnyObject) {
        NetworkManager.currentManager.doDisconnect({
            self.refreshSelectors()
        })
    }
}

class PrinterProfileData:NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var profiles:[[String:String]]?
    var pref:String = "_default"
    let picker:UIPickerView
    
    init(picker: UIPickerView){
        self.picker = picker
        super.init()
        picker.dataSource = self
        picker.delegate = self
    }
    
    func reload(){
        picker.reloadAllComponents()
        picker.selectRow(profiles!.indexOf({
            arr in
            return arr["id"]! == pref
        })!, inComponent: 0, animated: true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let arr = profiles {
            return arr.count
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return profiles![row]["name"]
    }
}
class SerialPortData:NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var ports:[String]?
    var pref:String = "_default"
    let picker:UIPickerView
    
    init(picker:UIPickerView){
        self.picker = picker
        super.init()
        picker.dataSource = self
        picker.delegate = self
    }
    
    func reload(){
        picker.reloadAllComponents()
        picker.selectRow((ports?.indexOf(pref))!, inComponent: 0, animated: true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let arr = ports {
            return arr.count
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ports![row]
    }
    
}

class BaudRateData:NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var rates:[Int]?
    var pref:Int = 0
    let picker:UIPickerView
    
    init(picker:UIPickerView){
        self.picker = picker
        super.init()
        picker.dataSource = self
        picker.delegate = self
    }
    
    func reload(){
        picker.reloadAllComponents()
        if pref == 0 {
            picker.selectRow(0, inComponent: 0, animated: true)
        } else {
            picker.selectRow((rates?.indexOf(pref))!+1, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let arr = rates {
            return (arr.count)+1
        } else {
            return 1
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Auto"
        } else {
            return String(rates![row-1])
        }
    }
    
    
    
}