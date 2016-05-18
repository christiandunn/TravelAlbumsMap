//
//  DirectoryLoaderWindowController.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/17/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class DirectoryLoaderWindowController : NSWindowController {
    
    public var VC : DirectoryLoaderViewController? = nil;
    
    override public func windowDidLoad() {
        
        self.window?.center();
        
        VC = self.contentViewController as? DirectoryLoaderViewController;
    }
}