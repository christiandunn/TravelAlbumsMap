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
    
    public var URL : NSURL;
    public var Location : CLLocationCoordinate2D?;
    private var DateString : String? = nil;
    public var Date : NSDate;
    
    init(withURL url : NSURL, andLocation location: CLLocationCoordinate2D?, andDate date: String?) {
        
        URL = url;
        Location = location;
        DateString = date;
        
        Date = NSDate.distantFuture();
        if DateString != nil {
            let result = CDMediaObjectFactory.dateFromDateString(withString: DateString!);
            if result != nil {
                Date = result!;
            }
        }
    }
    
    init(withURL url : NSURL, andLocation location: CLLocationCoordinate2D?, andDate date: NSDate?) {
        
        URL = url;
        Location = location;
        
        Date = NSDate.distantFuture();
        if date != nil {
            Date = date!;
        }
    }
}

public class CDMediaObjectFactory {
    
    public static func createMediaObject(withUrl Url : NSURL) -> CDMediaObjectWithLocation {
        
        let location = MediaLibraryAccessor.getLocation(Url);
        let date = MediaLibraryAccessor.getExifDateTimeOriginal(Url);
        
        if (CLLocationCoordinate2DIsValid(location)) {
            return CDMediaObjectWithLocation.init(withURL: Url, andLocation: location, andDate: date);
        } else {
            return CDMediaObjectWithLocation.init(withURL: Url, andLocation: nil, andDate: date);
        }
    }
    
    public static func createFromMlMediaObject(withObject object : MLMediaObject) -> CDMediaObjectWithLocation {
        
        let latitude = object.attributes["latitude"] as! Double;
        let longitude = object.attributes["longitude"] as! Double;
        let url = object.URL;        
        let loc = CLLocationCoordinate2DMake(latitude, longitude);
        
        var date : NSDate? = nil;
        if object.attributes.indexForKey("DateAsTimerInterval") != nil {
            let dateAsTimerInterval = object.attributes["DateAsTimerInterval"] as! Double;
            let newDate = NSDate.init(timeIntervalSinceReferenceDate: dateAsTimerInterval);
            date = newDate;
        }
        
        return CDMediaObjectWithLocation.init(withURL: url!, andLocation: loc, andDate: date);
    }
    
    public static func dateFromDateString(withString string : String) -> NSDate? {
        
        let dateString : String! = string;
        let dateFormatter : NSDateFormatter = NSDateFormatter.init();
        let dateFormat : String = "yyyy:MM:dd HH:mm:ss";
        dateFormatter.dateFormat = dateFormat;
        dateFormatter.formatterBehavior = NSDateFormatterBehavior.Behavior10_4;
        let date = dateFormatter.dateFromString(dateString);
        return date;
    }
}