//
//  temperatures.swift
//  Octo Print
//
//  Created by William Young on 3/10/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit
import SwiftyJSON

class TemperatureManager: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var HotendPicker: UIPickerView!
    @IBOutlet weak var BedPicker: UIPickerView!
    @IBOutlet weak var HotendText: UITextField!
    @IBOutlet weak var BedText: UITextField!
    @IBOutlet weak var HotendCurrent: UILabel!
    @IBOutlet weak var BedCurrent: UILabel!
    @IBOutlet weak var PresetDesclamer: UILabel!
    
    static var timer:NSTimer?
    
    //Temporary stuff
    var hasHeatedBed = true
    
    func startTimers(){
        TemperatureManager.timer?.invalidate()
        TemperatureManager.timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(TemperatureManager.updateTemps), userInfo: nil, repeats: true)
    }
    
    func getCleanString(input:String) -> String {
        let charactersToRemove = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        return input.componentsSeparatedByCharactersInSet(charactersToRemove).joinWithSeparator("")
    }
    
    func sendTemps(){
        HotendText.text = getCleanString(HotendText.text!)
        BedText.text = getCleanString(BedText.text!)
        NetworkManager.currentManager.setToolTemp("tool0", temp: Int(getCleanString((HotendText.text?.isEmpty == true ? "0" : HotendText.text!)))!, closure: {
            self.updateTemps()
            self.startTimers()
        })
        NetworkManager.currentManager.setBedTemp(Int(getCleanString((BedText.text?.isEmpty == true ? "0" : BedText.text!)))!,closure: {
            self.updateTemps()
            self.startTimers()
        })
    }
    
    //VC stuff
    
    override func viewWillAppear(animated: Bool) {
        HotendPicker.reloadAllComponents()
        BedPicker.reloadAllComponents()
        if settings.currentSettings?.tempPresets == nil || settings.currentSettings?.tempPresets?.count == 0 {
            PresetDesclamer.hidden = false
        } else {
            PresetDesclamer.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimers();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TemperatureManager.startTimers), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TemperatureManager.startTimers), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        
        if !hasHeatedBed{
            BedPicker.alpha = 0.6
            BedPicker.userInteractionEnabled = false
            BedText.enabled = false
            BedCurrent.enabled = false
        }
        
        HotendPicker.dataSource = self
        BedPicker.dataSource = self
        HotendPicker.delegate = self
        BedPicker.delegate = self
        HotendText.delegate = self
        BedText.delegate = self
        
        updateTemps()
        
    }
    
    func updateTemps(){
        NetworkManager.currentManager.getTemperatures({
            json in
            self.HotendCurrent.text = json["tool0"]!["actual"].stringValue
            self.BedCurrent.text = json["bed"]!["actual"].stringValue
            self.HotendText.text = json["tool0"]!["target"].stringValue
            self.BedText.text = json["bed"]!["target"].stringValue
        })
    }
    
    
    
    //PVD stuff
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var names:[String] = []
        
        if let presets = settings.currentSettings?.tempPresets {
            for name in presets.keys{
                names.append(name)
            }
        }
        switch pickerView {
        case HotendPicker:
            if row == 0 {
                return "Off (0)"
            }
            return "\((settings.currentSettings?.tempPresets![names[row-1]]?.name)!) (\((settings.currentSettings?.tempPresets![names[row-1]]?.hotEnd[0])!))"
        case BedPicker:
            if row == 0 {
                return "Off (0)"
            }
            return "\((settings.currentSettings?.tempPresets![names[row-1]]?.name)!) (\((settings.currentSettings?.tempPresets![names[row-1]]?.bed)!))"
        default:
            return "Error"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var names:[String] = []
        
        if let presets = settings.currentSettings?.tempPresets {
            for name in presets.keys{
                names.append(name)
            }
        }
        
        switch pickerView {
        case HotendPicker:
            if row == 0 {
                HotendText.text = "0"
                sendTemps()
                return
            }
            HotendText.text = String((settings.currentSettings?.tempPresets![names[row-1]]?.hotEnd[0])!)
            sendTemps()
            break
        case BedPicker:
            if row == 0 {
                BedText.text = "0"
                sendTemps()
                return
            }
            BedText.text = String((settings.currentSettings?.tempPresets![names[row-1]]?.bed)!)
            sendTemps()
            break
        default:
            break
        }
    }
    
    //PVDS stuff
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case HotendPicker:
            if let hotendPresets = settings.currentSettings?.tempPresets {
                return (hotendPresets.count)+1 //send data now
            }
            return 1
        case BedPicker:
            if let bedPresets = settings.currentSettings?.tempPresets {
                return (bedPresets.count)+1 //send data now
            }
            return 1
        default:
            return 0
        }
    }
    
    //Tap Gesture Recognizer
    
    @IBAction func tapPreformed(sender: AnyObject) {
        self.view.endEditing(true) //Send data now
    }
    
    //TFD
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        TemperatureManager.timer?.invalidate()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        startTimers()
        sendTemps()
    }
    
}