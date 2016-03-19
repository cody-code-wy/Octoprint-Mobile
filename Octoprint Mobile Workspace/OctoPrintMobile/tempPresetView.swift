//
//  tempPresetView.swift
//  Octo Print
//
//  Created by William Young on 3/14/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit

class tempPresetView:UITableViewController {
    
    let reuseId = "TempPreset"
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = settings.currentSettings?.tempPresets?.count {
            return count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseId)!
        
        let preset = cell as! tempPresetCell
        
        var names:[String] = []
        
        for name in (settings.currentSettings?.tempPresets?.keys)!{
            names.append(name)
        }
        
        preset.presetName.text = names[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tempPresetDetail" {
            let selection = sender as! tempPresetCell
            let detail = segue.destinationViewController as! PresetViewer
            detail.preset = selection.presetName.text
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        var names:[String] = []
        
        for name in (settings.currentSettings?.tempPresets?.keys)!{
            names.append(name)
        }
        settings.currentSettings?.tempPresets?.removeValueForKey(names[indexPath.row])
        settings.currentSettings?.saveSettings()
        self.tableView.reloadData()
    }
    
}

class tempPresetCell:UITableViewCell {
    
    @IBOutlet weak var presetName: UILabel!
    
}