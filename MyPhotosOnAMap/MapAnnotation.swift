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
    
    public var Objects : [MLMediaObject] = [];
    public var Center : CLLocationCoordinate2D? = nil;
    public var Coords : [CLLocationCoordinate2D] = [];
    
    init(withMediaObject object: MLMediaObject, andCoord: CLLocationCoordinate2D) {
        Objects.append(object);
        Coords.append(andCoord);
        Center = andCoord;
    }
    
    init(withMediaObjects objects: [MLMediaObject], andCluster cluster: ClusterOfCoordinates) {
        let coords = cluster.Points;
        Objects.appendContentsOf(objects);
        Coords.appendContentsOf(coords);
        Center = cluster.Center;
    }
}

public class ClusterOfCoordinates {
    
    public var Center : CLLocationCoordinate2D;
    public var Points : [CLLocationCoordinate2D];
    
    init(withCenter center : CLLocationCoordinate2D, andPoints points : [CLLocationCoordinate2D]) {
        Center = center;
        Points = points;
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
        let coords : [CLLocationCoordinate2D] = DataLoad.Coords;
        let minLat = coords.reduce(9999999, combine: {min($0, $1.latitude)});
        let minLon = coords.reduce(9999999, combine: {min($0, $1.longitude)});
        let maxLat = coords.reduce(-9999999, combine: {max($0, $1.latitude)});
        let maxLon = coords.reduce(-9999999, combine: {max($0, $1.longitude)});
        
        let span = MKCoordinateSpanMake(maxLat - minLat, maxLon - minLon);
        let region = MKCoordinateRegionMake(DataLoad.Center!, span);
        return region;
    }
}

public class ImageRep {
    private var MediaObject : MLMediaObject;
    
    init(imageRepWithMediaObject mediaObject : MLMediaObject) {
        MediaObject = mediaObject;
    }
    
    @objc public func imageUID() -> String! {
        return MediaObject.identifier;
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
        return MediaLibraryAccessor.getExifDateTimeOriginal(MediaObject.URL);
    }
    
    @objc public func imageSubtitle() -> String! {
        let altitude = MediaLibraryAccessor.getGpsAltitude(MediaObject.URL);
        if altitude != nil {
            return String(format: "%.2fm", altitude.doubleValue);
        }
        return "";
    }
    
    @objc public func isSelectable() -> Bool {
        return true;
    }
}