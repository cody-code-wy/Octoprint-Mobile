//
//  UploadView.swift
//  Octo Print
//
//  Created by William Young on 3/14/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit

class UploadView: UIViewController {
    
    var url:NSURL?
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var ProgressBar: UIProgressView!
    
    override func viewDidLoad() {
        
        NameLabel.text = url!.lastPathComponent!
        
        NetworkManager.currentManager.doUpload(url!, cleanup: {
            let fileManage = NSFileManager()
            do {
                try fileManage.removeItemAtURL(self.url!)
            }
            catch let error as NSError {
                print(error)
            }
            
            self.dismissViewControllerAnimated(true, completion: {})
            
            }, progress: {
                percent in
                print(percent)
                dispatch_async(dispatch_get_main_queue()){
                    self.ProgressBar.setProgress(percent, animated: true)
                }
        })
    }
    
}
