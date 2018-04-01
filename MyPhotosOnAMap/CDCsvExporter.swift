//
//  CDCsvExporter.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/15/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class CDCsvExporter {
    
    var Path : NSURL;
    var Items : [CDMediaObjectWithLocation];
    
    init(withPath path: NSURL, andItems items: [CDMediaObjectWithLocation]) {
        
        Path = path;
        Items = items;
    }
    
    public func export() -> Bool {
        
        let firstLine = "FileName, Latitude, Longitude, Date";
        var lines = Items.map({(o : CDMediaObjectWithLocation) -> String in "\"\(o.URL.absoluteString)\", \(o.Location?.latitude ?? -999), \(o.Location?.longitude ?? -999), \(o.Date)"});
        lines.insert(firstLine, at: 0);
        let output = lines.reduce("") { $0.isEmpty ? $1 : "\($0)\n\($1)" };
        do {
            try output.write(to: Path as URL, atomically: true, encoding: String.Encoding.utf8);
        } catch {
            return false;
        }
        return true;
    }
}
