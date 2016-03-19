//
//  PresetViewer.swift
//  Octo Print
//
//  Created by William Young on 3/14/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit

class PresetViewer:UIViewController {
    
    var preset:String?
    
    var displayPreset:TemperaturePreset?
    
    @IBOutlet weak var HotendTemp: UILabel!
    
    @IBOutlet weak var HeatedBedTemp: UILabel!
    
    override func viewDidLoad() {
        if preset == nil {
            return
        }
        if let select = settings.currentSettings?.tempPresets![preset!] {
            displayPreset = select
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if preset == nil {
            return
        }
        if let select = settings.currentSettings?.tempPresets![preset!] {
            displayPreset = select
        }
        self.title = (displayPreset?.name)!
        let hotEndTemp:Int = (displayPreset?.hotEnd[0])!
        HotendTemp.text! = String(hotEndTemp) + "ºC"
        let bedTemp:Int = (displayPreset?.bed)!
        HeatedBedTemp.text! = String(bedTemp) + "ºC"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editPreset" {
            let editor = segue.destinationViewController as! PresetCreator
            editor.editingPreset = true
            editor.presetToEdit = preset
        }
    }
    
    @IBAction func doDelete(sender: AnyObject) {
        let deleteWarning = UIAlertController(title: "Delete Preset", message: "This action cannot be undone", preferredStyle: UIAlertControllerStyle.ActionSheet)
        deleteWarning.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
            _ in
            settings.currentSettings?.tempPresets?.removeValueForKey(self.preset!)
            settings.currentSettings?.saveSettings()
            self.navigationController?.popViewControllerAnimated(true)
        }))
        deleteWarning.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {_ in}))
        presentViewController(deleteWarning, animated: true, completion: {})
    }
    
    
}