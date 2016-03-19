//
//  statusView.swift
//  Octo Print
//
//  Created by William Young on 3/15/16.
//  Copyright © 2016 William Young. All rights reserved.
//


import UIKit

class StatusView:UIViewController {
    
    @IBOutlet weak var TimeToComplete: UILabel!
    
    @IBOutlet weak var Progress: UIProgressView!
    
    @IBOutlet weak var TotalPrintTime: UILabel!
    
    @IBOutlet weak var ElapsedTime: UILabel!
    
    @IBOutlet weak var PauseButton: UIBarButtonItem!
    
    @IBOutlet weak var PlayButton: UIBarButtonItem!
    
    @IBOutlet weak var PrintButton: UIBarButtonItem!
    
    @IBOutlet weak var CancelButton: UIBarButtonItem!
    
    func doUpdates(){
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    
    
}