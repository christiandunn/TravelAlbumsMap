//
//  WindowController.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/15/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class WindowController : NSWindowController {
    
    var VC : ViewController?;
    
    @IBOutlet weak var BackButton: NSToolbarItem!
    @IBOutlet weak var ForwardButton: NSToolbarItem!
    @IBOutlet weak var ZoomSlider: NSToolbarItem!
    @IBOutlet weak var Zoom: NSSlider!
    
    override public func windowDidLoad() {
        
        VC = self.window!.contentViewController as! ViewController?;
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        VC?.backButtonPressed();
        BackButton.enabled = false;
        ForwardButton.enabled = true;
    }
    
    @IBAction func forwardButtonPressed(sender: AnyObject) {
        VC?.forwardButtonPressed();
        ForwardButton.enabled = false;
        BackButton.enabled = true;
    }
    
    @IBAction func sliderDidAct(sender: AnyObject) {
        VC?.setImageBrowserZoom(Float(Zoom.doubleValue/100.0));
    }
}