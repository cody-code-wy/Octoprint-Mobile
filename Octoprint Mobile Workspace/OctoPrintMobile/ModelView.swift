//
//  ModelView.swift
//  Octo Print
//
//  Created by William Young on 3/11/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit
import SwiftyJSON

class ModelView: UIViewController {
    
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var Date: UILabel!
    
    var data:[String:JSON] = [:]
    
    override func viewDidLoad() {
        let date = data["date"]?.intValue
        
        self.title = data["name"]?.stringValue
        fileSize.text = NSByteCountFormatter.stringFromByteCount((data["size"]?.int64Value)!, countStyle: NSByteCountFormatterCountStyle.Binary)
        
        
        let nsdate = NSDate(timeIntervalSince1970: NSTimeInterval(date!))
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        Date.text = formatter.stringFromDate(nsdate)
        
    }
    
    @IBAction func doDelete(sender: AnyObject) {
        let deleteAlert = UIAlertController(title: "Delete Model file", message: "You will not be able to undo this action.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (action) in
            
            NetworkManager.currentManager.doDelete((self.data["refs"]?.dictionaryValue["resource"]!.stringValue)!, closure: {
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            
            for tbi in self.toolbarItems! {
                tbi.enabled = false
            }
            self.view?.userInteractionEnabled=true
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) in }))
        
        presentViewController(deleteAlert, animated: true) {}
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "doSlice" {
            //Do Something!!!
        }
    }
    
}