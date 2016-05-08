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
    
    @IBOutlet weak var windowee: NSWindow!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        NSApplication.sharedApplication().mainWindow?.backgroundColor = NSColor.whiteColor();
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

