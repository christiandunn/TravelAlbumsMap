//
//  MapAnnotation.swift
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 5/5/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Cocoa
import MapKit
import Foundation
import Quartz

public class MapAnnotation {
    
    public var Objects : [CDMediaObjectWithLocation] = [];
    public var Center : CLLocationCoordinate2D? = nil;
    
    init(withMediaObject object: CDMediaObjectWithLocation, andCoord: CLLocationCoordinate2D) {
        Objects.append(object);
        Center = andCoord;
    }
    
    init(withMediaObjects objects: [CDMediaObjectWithLocation], andCluster cluster: ClusterOfCoordinates) {
        Objects.appendContentsOf(objects);
        Center = cluster.Center;
    }
    
    public func sortByDate() {
        Objects.sortInPlace({ $0.Date.timeIntervalSince1970 < $1.Date.timeIntervalSince1970 });
    }
    
    public func Coords(withIndex: Int) -> CLLocationCoordinate2D? {
        return Objects[withIndex].Location;
    }
}

public class ClusterOfCoordinates {
    
    public var Center : CLLocationCoordinate2D;
    public var Points : [CLLocationCoordinate2D];
    
    init(withCenter center : CLLocationCoordinate2D, andPoints points : [CLLocationCoordinate2D]) {
        Center = center;
        Points = points;
    }
    
    init(withPoints points: [CLLocationCoordinate2D]) {
        Points = points;
        let latSum = points.reduce(0.0, combine: {(_latSum, newCoord) in return _latSum + newCoord.latitude});
        let lonSum = points.reduce(0.0, combine: {(_lonSum, newCoord) in return _lonSum + newCoord.longitude});
        Center = CLLocationCoordinate2DMake(latSum / Double(points.count), lonSum / Double(points.count));
    }
}

public protocol ModifiedAnnotation {
    
    var DataLoad : MapAnnotation {get set}
}

public class ModifiedPinAnnotation : MKPointAnnotation, ModifiedAnnotation {
    
    public var DataLoad : MapAnnotation;
    
    init(withDataLoad data: MapAnnotation) {
        DataLoad = data;
    }
}

public class ModifiedClusterAnnotation : MKPointAnnotation, ModifiedAnnotation {
    
    public var DataLoad : MapAnnotation;
    
    init(withDataLoad data: MapAnnotation) {
        DataLoad = data;
    }
    
    public func enclosingRegion() -> MKCoordinateRegion {
        let coords : [CLLocationCoordinate2D] = DataLoad.Objects.map {$0.Location!};
        let minimumVisibleLatitude = 0.01;
        let mapPadding = 1.1;
        
        let minLat = coords.reduce(9999999, combine: {min($0, $1.latitude)});
        let minLon = coords.reduce(9999999, combine: {min($0, $1.longitude)});
        let maxLat = coords.reduce(-9999999, combine: {max($0, $1.latitude)});
        let maxLon = coords.reduce(-9999999, combine: {max($0, $1.longitude)});
        
        let center = CLLocationCoordinate2DMake((maxLat + minLat) / 2.0, (maxLon + minLon) / 2.0);
        var latSpan = (maxLat - minLat) * mapPadding;
        latSpan = latSpan < minimumVisibleLatitude ? minimumVisibleLatitude : latSpan;
        let lonSpan = (maxLon - minLon) * mapPadding
        
        let span = MKCoordinateSpanMake(latSpan, lonSpan);
        let region = MKCoordinateRegionMake(center, span);
        return region;
    }
}

public class ImageRep {
    private var MediaObject : CDMediaObjectWithLocation;
    
    init(imageRepWithMediaObject mediaObject : CDMediaObjectWithLocation) {
        MediaObject = mediaObject;
    }
    
    @objc public func imageUID() -> String! {
        return MediaObject.URL.absoluteString;
    }
    
    @objc public func imageRepresentationType() -> String! {
        return IKImageBrowserNSURLRepresentationType;
    }
    
    @objc public func imageRepresentation() -> AnyObject! {
        return MediaObject.URL;
    }
    
    @objc public func IKImageRepresentationWithType(type: String!) -> AnyObject! {
        return MediaObject.URL;
    }
    
    @objc public func imageVersion() -> Int {
        return 1;
    }
    
    @objc public func imageTitle() -> String! {
        let imageFileDetails = ImageFileDetails.init(path: MediaObject.URL);
        let dateString : String! = imageFileDetails.getExifDateTimeOriginal();
        let dateFormatter : NSDateFormatter = NSDateFormatter.init();
        let dateFormat : String = "yyyy:MM:dd HH:mm:ss";
        dateFormatter.dateFormat = dateFormat;
        dateFormatter.formatterBehavior = NSDateFormatterBehavior.Behavior10_4;
        if dateString == nil {
            return "";
        }
        let date = dateFormatter.dateFromString(dateString);
        
        let currentDateFormatter : NSDateFormatter = NSDateFormatter.init();
        currentDateFormatter.locale = NSLocale.currentLocale();
        currentDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle;
        if date == nil {
            return "";
        }
        return currentDateFormatter.stringFromDate(date!);
    }
    
    @objc public func imageSubtitle() -> String! {
        let imageFileDetails = ImageFileDetails.init(path: MediaObject.URL);
        let altitude = imageFileDetails.getGpsAltitude();
        if altitude != nil {
            let alt = altitude.doubleValue;
            return CustomDistanceFormatter.init().stringWithDistance(alt);
        }
        return "";
    }
    
    @objc public func isSelectable() -> Bool {
        return true;
    }
}