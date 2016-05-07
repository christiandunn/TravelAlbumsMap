//
//  ViewController.swift
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 4/19/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Cocoa
import MapKit
import Foundation
import Quartz

class ViewController: NSViewController, MKMapViewDelegate {

    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    @IBOutlet weak var ImageBrowser: IKImageBrowserView!
    
    var LatLons : [(CLLocationCoordinate2D, MLMediaObject)] = [];
    var FriendsNeededToNotBeLonely : Int = 10;
    var Closeness : Double = 32.0;
    var Clustering : ClusteringAlgorithm<MLMediaObject>? = nil;
    var Timing : NSTimer? = nil;
    var annotations : [ModifiedPinAnnotation] = [];
    var currentAnno : ModifiedPinAnnotation? = nil;
    
    let accessor = MediaLibraryAccessor();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self;
        Clustering = ClusteringAlgorithm<MLMediaObject>(withMaxDistance: Closeness * 1.5);
        
        ProgressBar.hidden = false;
        ProgressBar.startAnimation(self);
        accessor.setDelegate(self, withSelector: "mediaAccessorDidFinishLoadingAlbums");
        accessor.initialize();
        
        ImageBrowser.setDataSource(self);
        ImageBrowser.setCellsStyleMask(IKCellsStyleTitled + IKCellsStyleSubtitled);
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func mediaAccessorDidFinishLoadingAlbums() {
        
        ProgressBar.hidden = true;
        let mediaObjects: Array<MLMediaObject> = accessor.getMediaObjects() as NSArray as! [MLMediaObject];
        let attributes = mediaObjects.map {($0.attributes, $0)}.filter {$0.0.indexForKey("latitude") != nil}.filter {$0.0.indexForKey("longitude") != nil};
        let latLons = attributes.map {(CLLocationCoordinate2DMake($0.0["latitude"] as! Double, $0.0["longitude"] as! Double), $0.1)};
        LatLons = latLons;
        addPoints(LatLons);
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if Timing != nil {
            Timing?.invalidate();
            Timing = nil;
        }
        Timing = NSTimer.scheduledTimerWithTimeInterval(1.00, target: self, selector: #selector(refreshPoints), userInfo: nil, repeats: false);
    }
    
    @objc private func refreshPoints() {
        _removeAllCoordsFromMap();
        addPoints(LatLons);
    }

    private func addPoints(points: [(CLLocationCoordinate2D, MLMediaObject)]) {
        let mapViewPoints = points.map {(MapView.convertCoordinate($0.0, toPointToView: MapView), $0.1)}.filter {CGRectContainsPoint(MapView.frame, $0.0)};
        let mapViewCGPoints = mapViewPoints.map {$0.0};
        if mapViewPoints.count == 0 {
            return;
        }
        ProgressBar.hidden = false;
        ProgressBar.startAnimation(self);
        
        let lonelyPoints = mapViewPoints.filter {_countClosePoints($0.0, points: mapViewCGPoints) < FriendsNeededToNotBeLonely};
        let lonelyCoords = lonelyPoints.map {(MapView.convertPoint($0.0, toCoordinateFromView: MapView), $0.1)};
        _addLonelyCoordsToMap(lonelyCoords);
        
        let friendlyPoints = mapViewPoints.filter {_countClosePoints($0.0, points: mapViewCGPoints) >= FriendsNeededToNotBeLonely};
        if friendlyPoints.count == 0 {
            ProgressBar.hidden = true;
            return;
        }
        let (clusterCenters, maxD, clusterCounts) = Clustering!.kMeans(friendlyPoints);
        let clusterCoords = clusterCenters.map {(MapView.convertPoint($0.0, toCoordinateFromView: MapView), $0.1)};
        _addClusterCoordsToMap(clusterCoords, maxDs: maxD, clusterCounts: clusterCounts);
        ProgressBar.hidden = true;
    }
    
    private func _removeAllCoordsFromMap() {
        MapView.removeAnnotations(annotations);
    }
    
    private func _addLonelyCoordsToMap(coords: [(CLLocationCoordinate2D, MLMediaObject)]) {
        for coord in coords {
            let annotation = ModifiedPinAnnotation(withDataLoad: MapAnnotation(withMediaObject: coord.1));
            annotation.title = "Single Point";
            annotation.coordinate = coord.0;
            annotations.append(annotation);
            MapView.addAnnotation(annotation);
        }
    }
    
    private func _addClusterCoordsToMap(coords: [(CLLocationCoordinate2D, [MLMediaObject])], maxDs: [Double], clusterCounts: [Int]) {
        for i in 0...(coords.count - 1) {
            let coord = coords[i];
            let annotation = ModifiedPinAnnotation(withDataLoad: MapAnnotation(withMediaObjects: coord.1))
            annotation.coordinate = coord.0;
            annotation.title = "Cluster Size: \(clusterCounts[i])";
            annotation.subtitle = "Cluster Max Distance Away: \(maxDs[i])";
            annotations.append(annotation);
            MapView.addAnnotation(annotation);
        }
    }
    
    private func _countClosePoints(point: CGPoint, points: [CGPoint]) -> Int {
        let closeness = Closeness;
        var count = 0;
        
        for pt in points {
            let distance = _pointDistance(point, pt: pt);
            if Double(distance) < closeness {
                count += 1;
            }
        }
        
        return count - 1;
    }
    
    private func _pointDistance(point: CGPoint, pt: CGPoint) -> CGFloat {
        let distance = pow(pow(point.x - pt.x, 2) + pow(point.y - pt.y, 2), 0.5);
        return distance;
    }
    
    override func numberOfItemsInImageBrowser(aBrowser: IKImageBrowserView!) -> Int {
        return currentAnno?.DataLoad.Objects.count ?? 0;
    }
    
    override func imageBrowser(aBrowser: IKImageBrowserView!, itemAtIndex index: Int) -> AnyObject! {
        let mediaObject = currentAnno?.DataLoad.Objects[index] ?? nil;
        
        if mediaObject == nil {
            return nil;
        }
        
        return ImageRep(imageRepWithMediaObject: mediaObject!);
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let annotation = view.annotation;
        if let anno = annotation as? ModifiedPinAnnotation {
            currentAnno = anno;
            ImageBrowser.reloadData();
        }
    }
}

