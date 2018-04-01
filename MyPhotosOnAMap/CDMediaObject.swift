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
        
        Date = NSDate.distantFuture as NSDate;
        if DateString != nil && DateString?.compare("") != ComparisonResult.orderedSame {
            let result = CDMediaObjectFactory.dateFromDateString(withString: DateString!);
            if result != nil {
                Date = result!;
            }
        }
    }
    
    init(withURL url : NSURL, andLocation location: CLLocationCoordinate2D?, andDate date: NSDate?) {
        
        URL = url;
        Location = location;
        
        Date = NSDate.distantFuture as NSDate;
        if date != nil {
            Date = date!;
        }
    }
}

public class CDMediaObjectFactory {
    
    public static func createMediaObject(withUrl Url : NSURL) -> CDMediaObjectWithLocation {
        
        let imageFileDetails = ImageFileDetails.init(path: Url as URL!);
        let location = imageFileDetails?.getLocation();
        let date = imageFileDetails?.getExifDateTimeOriginal();
        
        if (imageFileDetails!.containsGpsMetadata() && CDMediaObjectFactory.locationIsLikely(location: location!)) {
            return CDMediaObjectWithLocation.init(withURL: Url, andLocation: location, andDate: date);
        } else {
            return CDMediaObjectWithLocation.init(withURL: Url, andLocation: nil, andDate: date);
        }
    }
    
    private static func locationIsLikely(location : CLLocationCoordinate2D) -> Bool {
        
        return CLLocationCoordinate2DIsValid(location) && !(fabs(location.latitude) < 0.01 && fabs(location.longitude) < 0.01);
    }
    
    public static func createFromMlMediaObject(withObject object : MLMediaObject) -> CDMediaObjectWithLocation {
        
        let latitude = object.attributes["latitude"] as! Double;
        let longitude = object.attributes["longitude"] as! Double;
        let url = object.url;        
        let loc = CLLocationCoordinate2DMake(latitude, longitude);
        
        var date : NSDate? = nil;
        if object.attributes.index(forKey: "DateAsTimerInterval") != nil {
            let dateAsTimerInterval = object.attributes["DateAsTimerInterval"] as! Double;
            let newDate = NSDate.init(timeIntervalSinceReferenceDate: dateAsTimerInterval);
            date = newDate;
        }
        
        return CDMediaObjectWithLocation.init(withURL: url as NSURL!, andLocation: loc, andDate: date);
    }
    
    public static func dateFromDateString(withString string : String) -> NSDate? {
        
        let dateString : String! = string;
        let dateFormatter : DateFormatter = DateFormatter.init();
        let dateFormat : String = "yyyy:MM:dd HH:mm:ss";
        dateFormatter.dateFormat = dateFormat;
        dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4;
        let date = dateFormatter.date(from: dateString);
        return date as NSDate?;
    }
}
