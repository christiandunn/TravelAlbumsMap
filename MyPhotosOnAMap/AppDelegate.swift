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
        
        NSApplication.shared().mainWindow?.backgroundColor = NSColor.white;
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        
        VC = ViewController.getMainViewController();
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction internal func openLibraryMenuAction(sender: NSMenuItem) {
        
        VC?.loadMapWithLibrary();
    }
    
    @IBAction internal func openDirectoryMenuAction(sender: NSMenuItem) {
        
        let itemLoader : ItemsInDirectoryLoader = ItemsInDirectoryLoader.init(withViewController: VC!);
        itemLoader.loadItemsFromDirectory();
    }
    
    @IBAction internal func exportAllPointsToCsv(sender: NSMenuItem) {
        SaveDialogService.init(withViewController: VC!).saveCsvAll();
    }
    
    @IBAction internal func exportVisiblePointsToCsv(sender: NSMenuItem) {
        SaveDialogService.init(withViewController: VC!).saveCsvVisible();
    }
}

