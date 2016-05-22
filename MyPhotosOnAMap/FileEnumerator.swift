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
        
        var usePath = path;
        FileManager = NSFileManager.defaultManager();
        var options: NSDirectoryEnumerationOptions = [NSDirectoryEnumerationOptions.SkipsHiddenFiles];
        if isPhotoLibrary(path) {
            options = options.union([NSDirectoryEnumerationOptions.SkipsPackageDescendants]);
            let masterFolderPath = path.URLByAppendingPathComponent("Masters", isDirectory: true);
            usePath = masterFolderPath;
        }
        DirectoryEnumerator = FileManager.enumeratorAtURL(usePath, includingPropertiesForKeys: nil, options: options, errorHandler: nil);
    }
    
    internal func getAllImageFiles(vc : ViewController, dlwc : DirectoryLoaderWindowController) {
        
        VC = vc;
        DLWC = dlwc;
        getAllObjects();
    }
    
    private func isPhotoLibrary(path : NSURL) -> Bool {
        
        return path.pathExtension?.compare("photoslibrary") == NSComparisonResult.OrderedSame ||
            path.pathExtension?.compare("photolibrary") == NSComparisonResult.OrderedSame;
    }
    
    private func getAllObjects() {
        
        var allObjects : [CDMediaObjectWithLocation] = [];
        DLWC?.VC?.setEnumerator(self);
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            while let element = self.DirectoryEnumerator?.nextObject() as! NSURL? {
                if self.hasImageSuffix(element) {
                    allObjects.append(CDMediaObjectFactory.createMediaObject(withUrl: element));
                } else {
                    continue;
                }
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
