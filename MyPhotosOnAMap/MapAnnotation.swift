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
    
    init(withMediaObject object: MLMediaObject) {
        Objects.append(object);
    }
    
    init(withMediaObjects objects: [MLMediaObject]) {
        Objects.appendContentsOf(objects);
    }
}

public class ModifiedPinAnnotation : MKPointAnnotation {
    
    public var DataLoad : MapAnnotation;
    
    init(withDataLoad data: MapAnnotation) {
        DataLoad = data;
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
        return MediaObject.imageTitle();
    }
    
    @objc public func imageSubtitle() -> String! {
        return MediaObject.imageSubtitle();
    }
    
    @objc public func isSelectable() -> Bool {
        return true;
    }
}