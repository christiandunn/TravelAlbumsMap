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
        let mapViewPoints = points.map {MapView.convertCoordinate($0, toPointToView: MapView)}.filter {CGRectContainsPoint(MapView.frame, $0)};
        let lonelyPoints = mapViewPoints.filter {_countClosePoints($0, points: mapViewPoints) < 10};
        let lonelyCoords = lonelyPoints.map {MapView.convertPoint($0, toCoordinateFromView: MapView)};
        _addLonelyCoordsToMap(lonelyCoords);
        
        let friendlyPoints = mapViewPoints.filter {_countClosePoints($0, points: mapViewPoints) >= 10};
        let (clusterCenters, maxD, clusterCounts) = _kMeansOuter(friendlyPoints);
        let clusterCoords = clusterCenters.map {MapView.convertPoint($0, toCoordinateFromView: MapView)};
        _addClusterCoordsToMap(clusterCoords, maxDs: maxD, clusterCounts: clusterCounts);
    }
    
    private func _kMeansOuter(points: [CGPoint]) -> ([CGPoint], [Double], [Int]) {
        var k = 1;
        var maxmaxD = 0.0;
        var (clusterCenters, maxD, clusterCounts) = _kMeans(k, points: points);
        maxmaxD = maxD.reduce(0.0) {max($0, $1)};
        while maxmaxD > 32.0 && k < 100 {
            k = k + 1;
            (clusterCenters, maxD, clusterCounts) = _kMeans(k, points: points);
            maxmaxD = maxD.reduce(0.0) {max($0, $1)};
            print("Trying k = \(k)");
        }
        return (clusterCenters, maxD, clusterCounts);
    }
    
    private func _kMeans(k: Int, points: [CGPoint]) -> ([CGPoint], [Double], [Int]) {
        var centers : [CGPoint] = [CGPoint]();
        var closest = points.map {($0, 0)};
        var centersMaxD = [Double]();
        var centersCount = [Int]();
        for i in 1...k {
            let s : Int = points.count * (i - 1) / k;
            centers.append(points[s]);
            centersMaxD.append(0.0);
            centersCount.append(0);
        }
        for _ in 1...10 {
            for p in 0...(closest.count-1) {
                //Find the closest existing center of index c to the point p
                var distance = 9999999.0;
                for c in 0...(k-1) {
                    let d = Double(_pointDistance(closest[p].0, pt: centers[c]));
                    if d < distance {
                        distance = d;
                        var oldClosest = closest[p];
                        oldClosest.1 = c;
                        closest[p] = oldClosest;
                    }
                }
            }
            //Recalculate the centers
            for c in 0...(k-1) {
                let pset = closest.filter {$0.1 == c};
                let newX = Double(pset.reduce(0) {$0 + $1.0.x})/Double(pset.count);
                let newY = Double(pset.reduce(0) {$0 + $1.0.y})/Double(pset.count);
                centers[c] = CGPointMake(CGFloat(newX), CGFloat(newY));
                
                let maxD = pset.reduce(0) {max($0, _pointDistance($1.0, pt: centers[c]))};
                centersMaxD[c] = Double(maxD);
                
                centersCount[c] = pset.count;
            }
        }
        return (centers, centersMaxD, centersCount);
    }
    
    private func _addLonelyCoordsToMap(coords: [CLLocationCoordinate2D]) {
        for coord in coords {
            let annotation = MKPointAnnotation();
            annotation.coordinate = coord;
            MapView.addAnnotation(annotation);
        }
    }
    
    private func _addClusterCoordsToMap(coords: [CLLocationCoordinate2D], maxDs: [Double], clusterCounts: [Int]) {
        for i in 0...(coords.count - 1) {
            let coord = coords[i];
            let annotation = MKPointAnnotation();
            annotation.coordinate = coord;
            annotation.title = "Cluster Size: \(clusterCounts[i])";
            annotation.subtitle = "Cluster Max Distance Away: \(maxDs[i])";
            MapView.addAnnotation(annotation);
        }
    }
    
    private func _countClosePoints(point: CGPoint, points: [CGPoint]) -> Int {
        let closeness = 16.0;
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
}

