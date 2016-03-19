//
//  controls.swift
//  Octo Print
//
//  Created by William Young on 3/11/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit

class controls: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        ExtrudeMM.delegate = self
    }
    
    let indexToScale = [1,10,100]
    
    @IBOutlet weak var MMSelected: UISegmentedControl!
    
    @IBOutlet weak var Stepper: UIStepper!
    
    @IBOutlet weak var ExtrudeMM: UITextField!
    
    @IBAction func HomeXY(sender: AnyObject) {
        NetworkManager.currentManager.homeAxes(true, y:true)
    }
    @IBAction func HomeZ(sender: AnyObject) {
        NetworkManager.currentManager.homeAxes(z:true)
    }
    
    @IBAction func JogYUp(sender: AnyObject) {
        NetworkManager.currentManager.sendJog(indexToScale[MMSelected.selectedSegmentIndex],y:1)
    }
    
    @IBAction func JogYDown(sender: AnyObject) {
        NetworkManager.currentManager.sendJog(indexToScale[MMSelected.selectedSegmentIndex],y:-1)
    }
    
    @IBAction func JogXUp(sender: AnyObject) {
        NetworkManager.currentManager.sendJog(indexToScale[MMSelected.selectedSegmentIndex],x:1)
    }
    
    @IBAction func JogXDown(sender: AnyObject) {
        NetworkManager.currentManager.sendJog(indexToScale[MMSelected.selectedSegmentIndex],x:-1)
    }
    
    @IBAction func JogZUp(sender: AnyObject) {
        NetworkManager.currentManager.sendJog(indexToScale[MMSelected.selectedSegmentIndex],z:1)
    }
    
    @IBAction func JogZDown(sender: AnyObject) {
        NetworkManager.currentManager.sendJog(indexToScale[MMSelected.selectedSegmentIndex],z:-1)
    }
    
    @IBAction func Retract(sender: AnyObject) {
        ExtrudeMM.text = getCleanString(ExtrudeMM.text!)
        NetworkManager.currentManager.extrudeAmount(-Int(Stepper.value))
    }
    
    @IBAction func Extrude(sender: AnyObject) {
        ExtrudeMM.text = getCleanString(ExtrudeMM.text!)
        NetworkManager.currentManager.extrudeAmount(Int(Stepper.value))
    }
    
    @IBAction func StepExtruder(sender: AnyObject) {
        ExtrudeMM.text = String(Int(Stepper.value))
    }
    
    @IBAction func ExtrudeTextChange(sender: AnyObject) {
        ExtrudeMM.text = getCleanString(ExtrudeMM.text!)
        if let num = ExtrudeMM.text{
            if num.isEmpty {
                return
            }
            Stepper.value = Double(num)!
        }
    }
    
    @IBAction func stopEditing(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    func getCleanString(input:String) -> String {
        let charactersToRemove = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        return input.componentsSeparatedByCharactersInSet(charactersToRemove).joinWithSeparator("")
    }
    
    
}