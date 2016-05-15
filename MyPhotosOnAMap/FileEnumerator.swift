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
    
    init(withPath path : NSURL) {
        
        FileManager = NSFileManager.defaultManager();
        let options: NSDirectoryEnumerationOptions = [.SkipsHiddenFiles, .SkipsPackageDescendants];
        DirectoryEnumerator = FileManager.enumeratorAtURL(path, includingPropertiesForKeys: nil, options: options, errorHandler: nil);
    }
    
    public func getAllImageFiles() -> [NSURL] {
        
        let allObjects = getAllObjects();
        let imageObjects = allObjects.filter({(URL : NSURL) -> Bool in hasImageSuffix(URL)});
        return imageObjects;
    }
    
    private func getAllObjects() -> [NSURL] {
        
        let allObjects = DirectoryEnumerator?.allObjects as! [NSURL];
        return allObjects;
    }
    
    private func hasImageSuffix(URL : NSURL) -> Bool {
        
        let stringValue = URL.absoluteString.lowercaseString;
        return stringValue.hasSuffix("jpeg") ||
            stringValue.hasSuffix("jpg") ||
            stringValue.hasSuffix("bmp") ||
            stringValue.hasSuffix("tiff") ||
            stringValue.hasSuffix("tif") ||
            stringValue.hasSuffix("gif");
    }
}
