//
//  DirectoryLoaderViewController.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/17/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class DirectoryLoaderViewController : NSViewController {
    
    @IBOutlet weak var ProgressBar : NSProgressIndicator!;
    @IBOutlet weak var Label : NSTextField!;
    
    var Enumerator : FileEnumerator? = nil;
    
    @IBAction func stopButtonPressed(sender: AnyObject) {
        
        Enumerator?.stopEnumerating();
    }
    
    public func updateLabel(labelText: String) {
        
        Label.stringValue = labelText;
    }
    
    public func setEnumerator(enumerator: FileEnumerator) {
        
        Enumerator = enumerator;
    }
}