//
//  CDMediaObject.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/15/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation
import MapKit

public class CDMediaObjectWithLocation {
    
    var URL : NSURL;
    var Location : CLLocationCoordinate2D?;
    
    init(withURL url : NSURL, andLocation location: CLLocationCoordinate2D?) {
        
        URL = url;
        Location = location;
    }
}

public class CDMediaObjectFactory {
    
    public static func createMediaObject(withUrl Url : NSURL) -> CDMediaObjectWithLocation {
        
        let location = MediaLibraryAccessor.getLocation(Url);
        if (CLLocationCoordinate2DIsValid(location)) {
            return CDMediaObjectWithLocation.init(withURL: Url, andLocation: location);
        } else {
            return CDMediaObjectWithLocation.init(withURL: Url, andLocation: nil);
        }
    }
    
    public static func createFromMlMediaObject(withObject object : MLMediaObject) -> CDMediaObjectWithLocation {
        
        let latitude = object.attributes["latitude"] as! Double;
        let longitude = object.attributes["longitude"] as! Double;
        let url = object.URL;
        let loc = CLLocationCoordinate2DMake(latitude, longitude);
        return CDMediaObjectWithLocation.init(withURL: url!, andLocation: loc);
    }
}