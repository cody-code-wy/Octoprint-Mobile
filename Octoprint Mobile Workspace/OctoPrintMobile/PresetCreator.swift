//
//  PresetCreator.swift
//  Octo Print
//
//  Created by William Young on 3/14/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit

class PresetCreator: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var PresetName: UITextField!
    
    @IBOutlet weak var HotendTemp: UITextField!
    @IBOutlet weak var HotendStepper: UIStepper!
    
    @IBOutlet weak var BedTemp: UITextField!
    @IBOutlet weak var BedStepper: UIStepper!
    
    var editingPreset:Bool = false
    var presetToEdit:String?
    var loadedPreset:TemperaturePreset?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editingPreset && presetToEdit != nil{
            self.title = "Edit Preset"
            loadedPreset = settings.currentSettings?.tempPresets![presetToEdit!]
            PresetName.text = loadedPreset?.name
            PresetName.enabled = false
            let hotend:Int = (loadedPreset?.hotEnd[0])!
            let bed:Int = (loadedPreset?.bed)!
            HotendTemp.text = String(hotend)
            HotendStepper.value = Double(hotend)
            
            BedTemp.text = String(bed)
            BedStepper.value = Double(bed)
        }
        
    }
    
    @IBAction func Tapped(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    
    
    @IBAction func CancelView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func SavePreset(sender: AnyObject) {
        if settings.currentSettings?.tempPresets == nil {
            settings.currentSettings?.tempPresets = [:]
        }
        self.view.endEditing(true)
        if let tempPreset = settings.currentSettings?.tempPresets {
            if tempPreset[PresetName.text!] != nil && editingPreset == false{
                let overwriteAlert = UIAlertController(title: "Overwrite preset", message: "There is already a preset nammed \(PresetName.text) this will replace it if you choose to overwrite.", preferredStyle: UIAlertControllerStyle.ActionSheet)
                overwriteAlert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Destructive, handler: { _ in
                    settings.currentSettings?.tempPresets![self.PresetName.text!] = TemperaturePreset(name: self.PresetName.text!, hotEnd: [Int(self.HotendStepper.value)], bed: Int(self.BedStepper.value))
                    self.dismissViewControllerAnimated(true, completion: {})
                }))
                overwriteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {_ in}))
                settings.currentSettings?.saveSettings()
                presentViewController(overwriteAlert, animated: true, completion: {})
                
            } else {
                settings.currentSettings?.tempPresets![PresetName.text!] = TemperaturePreset(name: PresetName.text!, hotEnd: [Int(HotendStepper.value)], bed: Int(BedStepper.value))
                settings.currentSettings?.saveSettings()
                self.dismissViewControllerAnimated(true, completion: {})
            }
        }
    }
    
    
    
    @IBAction func HotendStepped(sender: AnyObject) {
        HotendTemp.text = String(Int(HotendStepper.value))
    }
    @IBAction func HotendUpdated(sender: AnyObject) {
        HotendTemp.text = getCleanString(HotendTemp.text!)
        if let num = HotendTemp.text {
            if num.isEmpty {
                HotendStepper.value = 0.0
                return
            }
            HotendStepper.value = Double(num)!
        }
    }
    
    @IBAction func BedStepped(sender: AnyObject) {
        BedTemp.text = String(Int(BedStepper.value))
        
    }
    @IBAction func BedUpdated(sender: AnyObject) {
        BedTemp.text = getCleanString(BedTemp.text!)
        if let num = BedTemp.text {
            if num.isEmpty {
                BedStepper.value = 0.0
                return
            }
            BedStepper.value = Double(num)!
        }
    }
    
    
    
    func getCleanString(input:String) -> String {
        let charactersToRemove = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        return input.componentsSeparatedByCharactersInSet(charactersToRemove).joinWithSeparator("")
    }
    
    
    
}
