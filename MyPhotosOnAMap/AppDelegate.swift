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

    let accessor = MediaLibraryAccessor();

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        accessor.applicationDidFinishLaunching(aNotification);
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

