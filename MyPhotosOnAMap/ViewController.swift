//
//  ViewController.swift
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 4/19/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController {

    @IBOutlet weak var MapView: MKMapView!
    
    let accessor = MediaLibraryAccessor();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        accessor.initialize();
        accessor.setDelegate(self, withSelector: "mediaAccessorDidFinishLoadingAlbums");
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func mediaAccessorDidFinishLoadingAlbums() {
        
        let mediaObjects: Array<MLMediaObject> = accessor.getMediaObjects() as NSArray as! [MLMediaObject];
        let attributes = mediaObjects.map {$0.attributes}.filter {$0.indexForKey("latitude") != nil}.filter {$0.indexForKey("longitude") != nil};
        let latLons = attributes.map {CLLocationCoordinate2DMake($0["latitude"] as! Double, $0["longitude"] as! Double)};
        addPoints(latLons);
    }

    func addPoints(points: [CLLocationCoordinate2D]) {
        for point in points {
            let annotation = MKPointAnnotation();
            annotation.coordinate = point;
            MapView.addAnnotation(annotation);
        }
    }
}

