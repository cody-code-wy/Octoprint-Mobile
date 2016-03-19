//
//  SliceView.swift
//  Octo Print
//
//  Created by William Young on 3/13/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit
import SwiftyJSON

class SliceView:UIViewController {
    
    @IBAction func Cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}