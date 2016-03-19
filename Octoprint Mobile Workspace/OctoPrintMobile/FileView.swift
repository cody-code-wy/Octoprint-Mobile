//
//  FileView.swift
//  Octo Print
//
//  Created by William Young on 3/11/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit
import SwiftyJSON

class FileView: UITableViewController {
    
    var files:[String:JSON] = [:]
    
    let stlReuse = "FileStl"
    let gcoReuse = "FileGcode"
    
    func Reload(refresh:Bool=true) {
        self.refreshControl?.endRefreshing()
        NetworkManager.currentManager.getFileListing({
            json in
            self.files = json
            //print(json["files"]?.array![0].dictionary!["name"]!)
            if refresh {
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        Reload()
    }
    
    override func viewDidLoad() {
        
        self.tableView.allowsMultipleSelection = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.Reload), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing Files")
        self.refreshControl?.beginRefreshing()
        Reload()
    }
    
    @IBAction func ReloadTap(sender: AnyObject) {
        self.refreshControl?.beginRefreshing()
        Reload()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (files.count == 0) || (files["files"]?.dictionary?.count == 0) {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.width))
            label.text = "No files currently available\nPull down to refresh"
            label.textColor = UIColor.blackColor()
            label.numberOfLines = 0
            label.textAlignment = NSTextAlignment.Center
            label.sizeToFit()
            
            self.tableView.backgroundView = label
            
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            return 0
        }
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let flist = files["files"] {
            return flist.count
        }
        return 0
        
        
    }
override     
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch (files["files"]?.array![indexPath.row].dictionary!["type"]!.string)! {
        case "model":
            cell = tableView.dequeueReusableCellWithIdentifier(stlReuse, forIndexPath: indexPath)
            let stl = cell as! stlCell
            stl.name = (files["files"]?.array![indexPath.row].dictionary!["name"]!.string)!
            stl.data = (files["files"]?.array![indexPath.row].dictionary!)!
            stl.loadData()
        case "machinecode":
            cell = tableView.dequeueReusableCellWithIdentifier(gcoReuse, forIndexPath: indexPath)
            let gco = cell as! gcoCell
            gco.name = (files["files"]?.array![indexPath.row].dictionary!["name"]!.string)!
            gco.data = (files["files"]?.array![indexPath.row].dictionary!)!
            if let model = gco.data["links"]?.array {
                for poss in model {
                    if (poss.dictionaryValue["rel"] == "model"){
                        let index = files["files"]?.arrayValue.indexOf({
                            json in
                            if json.dictionaryValue["name"]!.stringValue == poss.dictionaryValue["name"]?.stringValue {
                                return true
                            }
                            
                            return false
                        })
                        gco.modelData = files["files"]?.arrayValue[index!].dictionary!
                    }
                }
            }
            gco.loadData()
        default:
            cell = UITableViewCell()
        }
    
    
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "stlDetail":
            let data = (sender as! stlCell).data
            (segue.destinationViewController as! ModelView).data = data
            return
        case "gcoDetail":
            let data = (sender as! gcoCell).data
            let fileData = (sender as! gcoCell).modelData
            (segue.destinationViewController as! CodeView).data = data
            (segue.destinationViewController as! CodeView).fileData = fileData
            return
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let deleteAlert = UIAlertController(title: "Delete Model file", message: "You will not be able to undo this action.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (action) in
            
            NetworkManager.currentManager.doDelete((self.files["files"]?.arrayValue[indexPath.row].dictionaryValue["refs"]?.dictionaryValue["resource"]!.stringValue)!, closure: {
                self.refreshControl?.beginRefreshing()
                self.Reload()
            })
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) in}))
        
        presentViewController(deleteAlert, animated: true, completion: {})
        
    }
    
    /*override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (files["files"]?.array![indexPath.row].dictionary!["type"]!.string)! {
        case "model":
            let data = files["files"]?.array![indexPath.row].dictionary!
            let destination = ModelView()
            destination.data = data!
            destination.performSegueWithIdentifier("stlDetail", sender: self)
            break
        case "machinecode":
            let data = files["files"]?.array![indexPath.row].dictionary!
            let destination = CodeView()
            destination.data = data!
            destination.performSegueWithIdentifier("gcoDetail", sender: self)
            break
        default:
            break
        }
    }*/
    
}

class stlCell: UITableViewCell {
    
    var name:String = "Unnamed STL"
    var data:[String:JSON] = [:]
    
    func loadData(){
        nameLabel.text = name
        if let origin = data["origin"]?.stringValue {
            if origin == "local" {
                location.image = UIImage(named: "computer")
            } else {
                location.image = UIImage(named: "SdCard")
            }
        } else {
            location.removeFromSuperview()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var location: UIImageView!
    
}

class gcoCell: UITableViewCell {
    
    var name:String = "Unnamed GCO"
    var data:[String:JSON] = [:]
    var modelData:[String:JSON]?

    func loadData(){
        nameLabel.text = name
        if let prints = data["prints"]?.dictionary {
            print(prints)
            print(name)
            if prints["last"]?.dictionary!["success"]?.boolValue == true {
                //change image
                status.image = UIImage(named: "Ok")
            } else {
                //change image
                status.image = UIImage(named: "Error")
            }
        } else {
            status.image = UIImage(named: "Unprinted")
        }
        if let origin = data["origin"]?.stringValue {
            if origin == "local" {
                location.image = UIImage(named: "computer")
            } else {
                location.image = UIImage(named: "SdCard")
            }
        } else {
            location.removeFromSuperview()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var location: UIImageView!
}