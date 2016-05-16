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
        Zoom.continuous = true;
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        VC?.backButtonPressed();
    }
    
    @IBAction func forwardButtonPressed(sender: AnyObject) {
        VC?.forwardButtonPressed();
    }
    
    @IBAction func sliderDidAct(sender: AnyObject) {
        VC?.setImageBrowserZoom(Float(Zoom.doubleValue/100.0));
    }
    
    @IBAction func openFolder(sender: AnyObject) {
        let itemLoader : ItemsInDirectoryLoader = ItemsInDirectoryLoader.init(withViewController: VC!);
        itemLoader.loadItemsFromDirectory();
    }
    
    @IBAction func openLibrary(sender: AnyObject) {
        VC?.loadMapWithLibrary();
    }
}