//
//  FileEnumerator.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/14/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class FileEnumerator {
    
    var FileManager : NSFileManager;
    var DirectoryEnumerator : NSDirectoryEnumerator?;
    
    var VC : ViewController? = nil;
    var DLWC : DirectoryLoaderWindowController? = nil;
    
    var StopFlag : Bool = false;
    
    init(withPath path : NSURL) {
        
        FileManager = NSFileManager.defaultManager();
        let options: NSDirectoryEnumerationOptions = [NSDirectoryEnumerationOptions.SkipsHiddenFiles, NSDirectoryEnumerationOptions.SkipsPackageDescendants];
        DirectoryEnumerator = FileManager.enumeratorAtURL(path, includingPropertiesForKeys: nil, options: options, errorHandler: nil);
    }
    
    internal func getAllImageFiles(vc : ViewController, dlwc : DirectoryLoaderWindowController) {
        
        VC = vc;
        DLWC = dlwc;
        getAllObjects();
    }
    
    private func getAllObjects() {
        
        var allObjects : [NSURL] = [];
        DLWC?.VC?.setEnumerator(self);
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            while let element = self.DirectoryEnumerator?.nextObject() as! NSURL? {
                allObjects.append(element);
                dispatch_async(dispatch_get_main_queue()) {
                    self.DLWC!.VC?.updateLabel(element.absoluteString);
                }
                usleep(1000);
                if self.StopFlag {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.DLWC?.close();
                    });
                    break;
                }
            }
            allObjects = allObjects.filter({(URL : NSURL) -> Bool in self.hasImageSuffix(URL)});
            dispatch_async(dispatch_get_main_queue()) {
                self.DLWC?.close();
                self.VC?.loadMapWithFilePaths(allObjects);
            }
        }
    }
    
    public func stopEnumerating() {
    
        StopFlag = true;
    }
    
    private func hasImageSuffix(URL : NSURL) -> Bool {
        
        let stringValue = URL.absoluteString.lowercaseString;
        return stringValue.hasSuffix("jpeg") ||
            stringValue.hasSuffix("jpg") ||
            stringValue.hasSuffix("bmp") ||
            stringValue.hasSuffix("png") ||
            stringValue.hasSuffix("tiff") ||
            stringValue.hasSuffix("tif") ||
            stringValue.hasSuffix("jpe") ||
            stringValue.hasSuffix("gif");
    }
}
