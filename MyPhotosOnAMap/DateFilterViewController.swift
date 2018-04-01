//
//  DateFilterViewController.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/16/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

class DateFilterViewController : NSViewController {
    
    @IBOutlet weak var StartDatePicker : NSDatePicker!
    @IBOutlet weak var FinishDatePicker : NSDatePicker!
    @IBOutlet weak var CheckBox : NSButton!
    
    override func viewDidLoad() {
        
        let VC : ViewController = ViewController.getMainViewController()!;
        
        StartDatePicker.dateValue = VC.DateFilterStart as Date;
        FinishDatePicker.dateValue = VC.DateFilterFinish as Date;
        let enabled = VC.DateFilterUse;
        
        CheckBox.state = enabled ? NSOnState : NSOffState;
        let datePickerBackgroundColor = enabled ? NSColor.white : NSColor.lightGray;
        StartDatePicker.isEnabled = enabled;
        StartDatePicker.backgroundColor = datePickerBackgroundColor;
        FinishDatePicker.isEnabled = enabled;
        FinishDatePicker.backgroundColor = datePickerBackgroundColor;
    }
    
    @IBAction func applyButtonPressed(sender: AnyObject) {
        
        let VC : ViewController = ViewController.getMainViewController()!;
        let enabled = CheckBox.state == NSOnState;
        VC.updateDateFilter(withEarliestDate: StartDatePicker.dateValue as NSDate, andFuturemostDate: FinishDatePicker.dateValue as NSDate, useDateFilter: enabled);
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        
        StartDatePicker.dateValue = Constants.DateFilterStartDefault as Date;
        FinishDatePicker.dateValue = Constants.DateFilterFinishDefault as Date;
        CheckBox.state = NSOffState;
    }
    
    @IBAction func checkboxChanged(sender: AnyObject) {
        
        let enabled = CheckBox.state == NSOnState;
        let datePickerBackgroundColor = enabled ? NSColor.white : NSColor.lightGray;
        StartDatePicker.isEnabled = enabled;
        StartDatePicker.backgroundColor = datePickerBackgroundColor;
        FinishDatePicker.isEnabled = enabled;
        FinishDatePicker.backgroundColor = datePickerBackgroundColor;
    }
}
