//
//  ItemsInDirectoryLoader.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/14/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation
import AppKit

public class ItemsInDirectoryLoader {
    
    var VC : ViewController;
    
    init(withViewController viewController : ViewController) {
        
        VC = viewController;
    }
    
    public func loadItemsFromDirectory() {
        
        getPath();
    }
    
    private func getPath() {
        
        let window = NSApplication.sharedApplication().mainWindow;
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        openPanel.beginSheetModalForWindow(window!, completionHandler: { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                self._loadItemsFromDirectory(withPath: openPanel.URL!);
            }
        });
    }
    
    private func _loadItemsFromDirectory(withPath path: NSURL) {
        
        let fileEnumerator : FileEnumerator = FileEnumerator.init(withPath: path);
        let imageFilePaths = fileEnumerator.getAllImageFiles();
        VC.loadMapWithFilePaths(imageFilePaths);
    }
}