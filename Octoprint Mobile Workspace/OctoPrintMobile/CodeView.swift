//
//  CodeView.swift
//  Octo Print
//
//  Created by William Young on 3/11/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class CodeView: UIViewController {
    
    //Constraints
    
    @IBOutlet weak var SuccessfulPrintsConst: NSLayoutConstraint!
    
    @IBOutlet weak var FailedPrintsConst: NSLayoutConstraint!
    
    @IBOutlet weak var PrintsVolumeConst: NSLayoutConstraint!
    
    @IBOutlet weak var PrintTimeConst: NSLayoutConstraint!
    
    //Lables for optional stuff
    @IBOutlet weak var SuccessfulPrintsTitle: UILabel!
    
    @IBOutlet weak var FailedPrintsTitle: UILabel!
    
    @IBOutlet weak var PrintVolumeTitle: UILabel!
    
    @IBOutlet weak var Cubed: UILabel!
    
    @IBOutlet weak var MM: UILabel!
    
    @IBOutlet weak var PrintTimeTitle: UILabel!
    
    
    //Actual values
    
    
    @IBOutlet weak var fileSize: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var successfulPrints: UILabel!
    
    @IBOutlet weak var failedPrints: UILabel!
    
    @IBOutlet weak var printVolume: UILabel!
    
    @IBOutlet weak var PrintTime: UILabel!
    
    @IBOutlet weak var goToModel: UIBarButtonItem!
    var data:[String:JSON] = [:]
    var fileData:[String:JSON]?
    
    override func viewDidLoad() {
        if (fileData) != nil {
            goToModel.enabled = true
        }
        
        self.title = data["name"]?.stringValue
        
        let upload = data["date"]?.intValue
        let nsdate = NSDate(timeIntervalSince1970: NSTimeInterval(upload!))
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        date.text = formatter.stringFromDate(nsdate)
        
        fileSize.text = NSByteCountFormatter.stringFromByteCount((data["size"]?.int64Value)!, countStyle: NSByteCountFormatterCountStyle.Binary)
        
        if let printData = data["prints"]?.dictionaryValue {
            if let success = printData["success"]?.intValue {
                if success != 0 {
                    successfulPrints.text = String(success)
                    successfulPrints.hidden = false
                    SuccessfulPrintsTitle.hidden = false
                    SuccessfulPrintsConst.constant = 8
                }
            }
            if let fail = printData["failure"]?.intValue {
                if fail != 0 {
                    failedPrints.text = String(fail)
                    failedPrints.hidden = false
                    FailedPrintsTitle.hidden = false
                    FailedPrintsConst.constant = 8
                }
            }
        }
        
        if let gcodeData = data["gcodeAnalysis"]?.dictionaryValue {
            if let volume = gcodeData["filament"]?.dictionaryValue["tool0"]?.dictionaryValue["volume"]{
                printVolume.text = String(volume)
                printVolume.hidden = false
                PrintVolumeTitle.hidden = false
                MM.hidden = false
                Cubed.hidden = false
                PrintsVolumeConst.constant = 8
            }
            if let time = gcodeData["estimatedPrintTime"]?.intValue {
                let formattedTime = "\(time/60/60):\(String(format: "%02d",time/60%60)):\(String(format: "%02d",time&60))"
                PrintTime.text = formattedTime
                PrintTime.hidden = false
                PrintTimeTitle.hidden = false
                PrintTimeConst.constant = 8
            }
        }
        
    }
    
    @IBAction func deleteItem(sender: AnyObject) {
        let deleteAlert = UIAlertController(title: "Delete Gcode file", message: "You will not be able to undo this action.", preferredStyle: UIAlertControllerStyle.ActionSheet)
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
    
    @IBAction func doPrint(sender: AnyObject) {
        let printAlert = UIAlertController(title: "Start Print?", message: "This will start the print immidiately on the printer", preferredStyle: UIAlertControllerStyle.ActionSheet)
        printAlert.addAction(UIAlertAction(title: "Print", style: UIAlertActionStyle.Default, handler: {_ in
                NetworkManager.currentManager.startPrint((self.data["refs"]?.dictionaryValue["resource"]!.stringValue)!)
        }))
        printAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {_ in}))
        presentViewController(printAlert, animated: true, completion: {})
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToModel" {
            (segue.destinationViewController as! ModelView).data = fileData!
        }
    }
    
}
