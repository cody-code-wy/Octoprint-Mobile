//
//  SettingsController.swift
//  Octo Print
//
//  Created by William Young on 3/10/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit

class SettingsController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var octoVersion: UILabel!
    @IBOutlet weak var urlText: UITextField!
    @IBOutlet weak var apikeyText: UITextField!
    override func viewDidLoad() {
        
        settings.reloadSettings()
        
        if let url = settings.currentSettings?.url {
            urlText.text = url
        }
        if let apikey = settings.currentSettings?.apikey {
            apikeyText.text = apikey
        }
        
        RetryConnection(self)
        
    }
    
    @IBAction func saveAndUpdate(sender: AnyObject) {
        let setting = settings.reloadSettings()
        setting.apikey = apikeyText.text
        setting.url = urlText.text
        setting.saveSettings()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    @IBAction func endEditingNow(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func RetryConnection(sender: AnyObject) {
        octoVersion.text = "Octoprint version: NOT CONNECTED"
        saveAndUpdate(self)
        NetworkManager.reload()
        NetworkManager.currentManager.getVersion({version in
            self.octoVersion.text = "Octoprint version: \(version)"
        })
    }

}