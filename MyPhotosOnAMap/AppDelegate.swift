//
//  AppDelegate.swift
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 4/19/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Cocoa
import MapKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var VC : ViewController?;

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        NSApplication.sharedApplication().mainWindow?.backgroundColor = NSColor.whiteColor();
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        
        VC = NSApplication.sharedApplication().mainWindow?.contentViewController as! ViewController?;
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction internal func openDirectoryMenuAction(sender: NSMenuItem) {
        
        let itemLoader : ItemsInDirectoryLoader = ItemsInDirectoryLoader.init(withViewController: VC!);
        itemLoader.loadItemsFromDirectory();
    }
}

