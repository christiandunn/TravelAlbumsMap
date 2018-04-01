//
//  FileEnumerator.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/14/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class FileEnumerator {
    
    var _FileManager : FileManager;
    var _DirectoryEnumerator : FileManager.DirectoryEnumerator?;
    
    var VC : ViewController? = nil;
    var DLWC : DirectoryLoaderWindowController? = nil;
    
    var StopFlag : Bool = false;
    
    init(withPath path : URL) {
        
        var usePath = path;
        _FileManager = FileManager.default;
        var options: FileManager.DirectoryEnumerationOptions = [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles];
        if !isPhotoLibrary(path: path as NSURL) {
            options = options.union([FileManager.DirectoryEnumerationOptions.skipsPackageDescendants]);
        }
        if isPhotoLibrary(path: path as NSURL) {
            let masterFolderPath = path.appendingPathComponent("Masters", isDirectory: true);
            usePath = masterFolderPath;
        }
        _DirectoryEnumerator = _FileManager.enumerator(at: usePath, includingPropertiesForKeys: nil, options: options, errorHandler: nil);
    }
    
    internal func getAllImageFiles(vc : ViewController, dlwc : DirectoryLoaderWindowController) {
        
        VC = vc;
        DLWC = dlwc;
        getAllObjects();
    }
    
    private func isPhotoLibrary(path : NSURL) -> Bool {
        
        return path.pathExtension?.compare("photoslibrary") == ComparisonResult.orderedSame ||
            path.pathExtension?.compare("photolibrary") == ComparisonResult.orderedSame;
    }
    
    private func getAllObjects() {
        
        var allObjects : [CDMediaObjectWithLocation] = [];
        DLWC?.VC?.setEnumerator(enumerator: self);
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            while let element = self._DirectoryEnumerator?.nextObject() as! NSURL? {
                if self.hasImageSuffix(URL: element) {
                    let newMediaObject = CDMediaObjectFactory.createMediaObject(withUrl: element);
                    if !(Constants.ThrowawayFileWithNoLocationData && newMediaObject.Location == nil) {
                        allObjects.append(newMediaObject);
                    }
                } else {
                    continue;
                }
                DispatchQueue.main.async {
                    autoreleasepool {
                        self.DLWC!.VC?.updateLabel(labelText: (element.absoluteString?.replacingOccurrences(of: "file:///", with: "/"))!);
                    }
                }
                usleep(1000);
                if self.StopFlag {
                    DispatchQueue.main.async {
                        self.DLWC?.close();
                    };
                    break;
                }
            }
            DispatchQueue.main.async {
                self.DLWC?.close();
                self.VC?.loadMapWithFilePaths(mediaObjects: allObjects);
            }
        }
    }
    
    public func stopEnumerating() {
    
        StopFlag = true;
    }
    
    private func hasImageSuffix(URL : NSURL) -> Bool {
        
        let stringValue = URL.absoluteString?.lowercased();
        return stringValue!.hasSuffix("jpeg") ||
            stringValue!.hasSuffix("jpg") ||
            stringValue!.hasSuffix("bmp") ||
            stringValue!.hasSuffix("png") ||
            stringValue!.hasSuffix("tiff") ||
            stringValue!.hasSuffix("tif") ||
            stringValue!.hasSuffix("jpe") ||
            stringValue!.hasSuffix("gif");
    }
}
