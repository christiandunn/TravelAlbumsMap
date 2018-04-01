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
        Objects.append(contentsOf: objects);
        Center = cluster.Center;
    }
    
    public func sortByDate() {
        Objects.sort(by: { $0.Date.timeIntervalSince1970 < $1.Date.timeIntervalSince1970 });
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
        let latSum = points.reduce(0.0, {(_latSum, newCoord) in return _latSum + newCoord.latitude});
        let lonSum = points.reduce(0.0, {(_lonSum, newCoord) in return _lonSum + newCoord.longitude});
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
        
        let minLat = coords.reduce(9999999, {min($0, $1.latitude)});
        let minLon = coords.reduce(9999999, {min($0, $1.longitude)});
        let maxLat = coords.reduce(-9999999, {max($0, $1.latitude)});
        let maxLon = coords.reduce(-9999999, {max($0, $1.longitude)});
        
        var center = CLLocationCoordinate2DMake((maxLat + minLat) / 2.0, (maxLon + minLon) / 2.0);
        var latSpan = (maxLat - minLat) * mapPadding;
        let additionalTopPadding = (maxLat - minLat) * (mapPadding - 1.0);
        latSpan = latSpan + additionalTopPadding;
        center.latitude = center.latitude + additionalTopPadding / 2.0;
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
        let imageFileDetails = ImageFileDetails.init(path: MediaObject.URL as URL!);
        let dateString : String! = imageFileDetails!.getExifDateTimeOriginal();
        let dateFormatter : DateFormatter = DateFormatter.init();
        let dateFormat : String = "yyyy:MM:dd HH:mm:ss";
        dateFormatter.dateFormat = dateFormat;
        dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4;
        if dateString == nil || dateString.compare("") == ComparisonResult.orderedSame {
            return "";
        }
        let date = dateFormatter.date(from: dateString);
        
        let currentDateFormatter : DateFormatter = DateFormatter.init();
        currentDateFormatter.locale = NSLocale.current;
        currentDateFormatter.dateStyle = .medium;
        if date == nil {
            return "";
        }
        return currentDateFormatter.string(from: date!);
    }
    
    @objc public func imageSubtitle() -> String! {
        let imageFileDetails = ImageFileDetails.init(path: MediaObject.URL as URL!);
        let altitude = imageFileDetails?.getGpsAltitude();
        if altitude != nil {
            let alt = altitude?.doubleValue;
            return CustomDistanceFormatter.init().string(withDistance: alt!);
        }
        return "";
    }
    
    @objc public func isSelectable() -> Bool {
        return true;
    }
}
