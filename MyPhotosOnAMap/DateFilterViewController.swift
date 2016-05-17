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
        
        StartDatePicker.dateValue = VC.DateFilterStart;
        FinishDatePicker.dateValue = VC.DateFilterFinish;
        let enabled = VC.DateFilterUse;
        
        CheckBox.state = enabled ? NSOnState : NSOffState;
        let datePickerBackgroundColor = enabled ? NSColor.whiteColor() : NSColor.lightGrayColor();
        StartDatePicker.enabled = enabled;
        StartDatePicker.backgroundColor = datePickerBackgroundColor;
        FinishDatePicker.enabled = enabled;
        FinishDatePicker.backgroundColor = datePickerBackgroundColor;
    }
    
    @IBAction func applyButtonPressed(sender: AnyObject) {
        
        let VC : ViewController = ViewController.getMainViewController()!;
        let enabled = CheckBox.state == NSOnState;
        VC.updateDateFilter(withEarliestDate: StartDatePicker.dateValue, andFuturemostDate: FinishDatePicker.dateValue, useDateFilter: enabled);
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        
        StartDatePicker.dateValue = Constants.DateFilterStartDefault;
        FinishDatePicker.dateValue = Constants.DateFilterFinishDefault;
        CheckBox.state = NSOffState;
    }
    
    @IBAction func checkboxChanged(sender: AnyObject) {
        
        let enabled = CheckBox.state == NSOnState;
        let datePickerBackgroundColor = enabled ? NSColor.whiteColor() : NSColor.lightGrayColor();
        StartDatePicker.enabled = enabled;
        StartDatePicker.backgroundColor = datePickerBackgroundColor;
        FinishDatePicker.enabled = enabled;
        FinishDatePicker.backgroundColor = datePickerBackgroundColor;
    }
}