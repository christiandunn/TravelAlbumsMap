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

    var MapView: MKMapView!
    var ProgressBar: NSProgressIndicator!
    var ImageBrowser: IKImageBrowserView!
    
    var LatLons : [(CLLocationCoordinate2D, CDMediaObjectWithLocation)] = [];
    var FriendsNeededToNotBeLonely : Int = Constants.MinimumPointsForCluster;
    var ClusterRadius : Double = Constants.ClusterRadius;
    var Clustering : ClusteringAlgorithm<MLMediaObject>? = nil;
    var Timing : NSTimer? = nil;
    var annotations : [ModifiedPinAnnotation] = [];
    var Overlays : [ModifiedClusterAnnotation] = [];
    var ImageBrowserDel : ImageBrowserDelegate? = nil;
    var verticalScroller : NSScroller? = nil;
    var HighlitPoint : MKPointAnnotation? = nil;
    let accessor = MediaLibraryAccessor();
    var YellowPinView : MKPinAnnotationView? = nil;
    var scrollView : NSScrollView!;
    
    var BackStack : CDStack<MKCoordinateRegion>? = nil;
    var ForwardStack : CDStack<MKCoordinateRegion>? = nil;
    var NavigatingWithBackOrForwardButtons : Bool = false;
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NSApplication.sharedApplication().mainWindow?.backgroundColor = NSColor.whiteColor();        
        Clustering = ClusteringAlgorithm<MLMediaObject>(withMaxDistance: ClusterRadius);
        
        BackStack = CDStack<MKCoordinateRegion>.init();
        ForwardStack = CDStack<MKCoordinateRegion>.init();
        
        ImageBrowser = IKImageBrowserView.init(frame: CGRectMake(0.0, 0.0, 1.0, 1.0));
        ImageBrowser.setIntercellSpacing(CGSizeMake(0.0, 0.0));
        ImageBrowser.setAllowsMultipleSelection(false);
        self.view.addSubview(ImageBrowser);
        ImageBrowserDel = ImageBrowserDelegate.init(imageBrowser: ImageBrowser, delegate: self);
        
        MapView = MKMapView.init(frame: CGRectMake(0.0, 0.0, 1.0, 1.0));
        MapView.mapType = MKMapType.Hybrid;
        MapView.showsScale = true;
        MapView.showsBuildings = true;
        MapView.showsCompass = true;
        MapView.showsZoomControls = true;
        MapView.delegate = self;
        self.view.addSubview(MapView);
        
        scrollView = NSScrollView.init(frame: ImageBrowser.frame);
        scrollView.documentView = ImageBrowser;
        scrollView.hasVerticalScroller = true;
        self.view.addSubview(scrollView);
        
        ProgressBar = NSProgressIndicator.init(frame: CGRectMake(0.0, 0.0, 100.0, 100.0));
        ProgressBar.style = NSProgressIndicatorStyle.SpinningStyle;
        ProgressBar.indeterminate = true;
        ProgressBar.displayedWhenStopped = true;
        ProgressBar.hidden = true;
        self.view.addSubview(ProgressBar);
    }
    
    override func viewDidLayout() {
        
        super.viewDidLayout();
        
        let width = self.view.frame.size.width;
        let height = self.view.frame.size.height;
        
        MapView.setFrameSize(CGSizeMake(width*0.75, height));
        scrollView.setFrameOrigin(CGPointMake(width*CGFloat(Constants.MapViewFraction), 0.0));
        scrollView.setFrameSize(CGSizeMake(width*CGFloat(1-Constants.MapViewFraction), height));
        ProgressBar.setFrameOrigin(CGPointMake(MapView.frame.size.width/2 - 50.0, MapView.frame.size.height/2 - 50.0));
    }
    
    func loadMapWithFilePaths(paths: [NSURL]) {
        
        ProgressBar.hidden = false;
        let mediaObjectsWithLocation = paths.map {CDMediaObjectFactory.createMediaObject(withUrl: $0)}.filter {$0.Location != nil};
        LatLons = mediaObjectsWithLocation.map {($0.Location!, $0)};
        refreshPoints();
    }
    
    func loadMapWithLibrary() {
        
        ProgressBar.hidden = false;
        ProgressBar.startAnimation(self);
        accessor.setDelegate(self, withSelector: "mediaAccessorDidFinishLoadingAlbums");
        accessor.initialize();
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
        let latLons = attributes.map {(CLLocationCoordinate2DMake($0.0["latitude"] as! Double, $0.0["longitude"] as! Double), CDMediaObjectFactory.createFromMlMediaObject(withObject: $0.1))};
        LatLons = latLons;
        addPoints(LatLons);
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let isRealChange = !NavigatingWithBackOrForwardButtons;
        
        if isRealChange {
            BackStack?.push(mapView.region);
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if Timing != nil {
            Timing?.invalidate();
            Timing = nil;
        }
        Timing = NSTimer.scheduledTimerWithTimeInterval(1.00, target: self, selector: #selector(refreshPoints), userInfo: nil, repeats: false);
        NavigatingWithBackOrForwardButtons = false;
    }
    
    @objc private func refreshPoints() {
        
        _removeAllCoordsFromMap();
        addPoints(LatLons);
    }

    private func addPoints(points: [(CLLocationCoordinate2D, CDMediaObjectWithLocation)]) {
        
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
        let (clusterCenters, maxD, clusterCounts, clusters) = Clustering!.kMeans(friendlyPoints);
        let clusterCoords = clusterCenters.map {(MapView.convertPoint($0.0, toCoordinateFromView: MapView), $0.1)};
        let clustersOfCoords = clusters.map({(c : Cluster) -> ClusterOfCoordinates in _convertClustersToCoordinate(c)});
        _addClusterCoordsToMap(clusterCoords, maxDs: maxD, clusterCounts: clusterCounts, clusters: clustersOfCoords);
        ProgressBar.hidden = true;
    }
    
    private func _convertClustersToCoordinate(cluster : Cluster) -> ClusterOfCoordinates {
        
        let center = MapView.convertPoint(cluster.Center, toCoordinateFromView: MapView);
        let points = cluster.Points.map({MapView.convertPoint($0, toCoordinateFromView: MapView)});
        return ClusterOfCoordinates.init(withCenter: center, andPoints: points);
    }
    
    private func _removeAllCoordsFromMap() {
        
        MapView.removeAnnotations(annotations);
        MapView.removeAnnotations(Overlays);
    }
    
    private func _addLonelyCoordsToMap(coords: [(CLLocationCoordinate2D, CDMediaObjectWithLocation)]) {
        
        for coord in coords {
            let annotation = ModifiedPinAnnotation(withDataLoad: MapAnnotation(withMediaObject: coord.1, andCoord:coord.0));
            annotation.coordinate = coord.0;
            annotations.append(annotation);
            MapView.addAnnotation(annotation);
        }
    }
    
    private func _addClusterCoordsToMap(coords: [(CLLocationCoordinate2D, [CDMediaObjectWithLocation])], maxDs: [Double], clusterCounts: [Int], clusters: [ClusterOfCoordinates]) {
        
        for i in 0...(coords.count - 1) {
            let coord = coords[i];
            let annotation = ModifiedClusterAnnotation(withDataLoad: MapAnnotation(withMediaObjects: coord.1, andCluster: clusters[i]));
            annotation.coordinate = coord.0;
            Overlays.append(annotation);
            MapView.addAnnotation(annotation);
        }
    }
    
    private func _countClosePoints(point: CGPoint, points: [CGPoint]) -> Int {
        
        let closeness = ClusterRadius;
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
        
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let annotation = view.annotation;
        
        if (annotation as? ModifiedPinAnnotation) != nil {
            _processPhotoDataAnnotation(view);
        }
        
        if (annotation as? ModifiedClusterAnnotation) != nil {
            _processPhotoDataAnnotation(view);
        }
    }
    
    private func _processPhotoDataAnnotation(view: MKAnnotationView) {
        
        let newRegion = ImageBrowserDel?.activateAnnotationView(view);
        
        if newRegion != nil {
            MapView.setRegion(newRegion!, animated: true);
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let anno = annotation as? ModifiedPinAnnotation {
            let pinView = MKPinAnnotationView.init(annotation: anno, reuseIdentifier: "\(anno.coordinate.latitude), \(anno.coordinate.longitude)");
            pinView.pinTintColor = NSColor.redColor();
            return pinView;
        }
        
        if let anno = annotation as? ModifiedClusterAnnotation {
            let pinView = MKPinAnnotationView.init(annotation: anno, reuseIdentifier: "\(anno.coordinate.latitude), \(anno.coordinate.longitude)");
            pinView.pinTintColor = NSColor.blueColor();
            return pinView;
        }
        
        if let anno = annotation as? MKPointAnnotation {
            if anno == HighlitPoint {
                let pinView = MKPinAnnotationView.init(annotation: anno, reuseIdentifier: "\(anno.coordinate.latitude), \(anno.coordinate.longitude)");
                pinView.pinTintColor = NSColor.yellowColor();
                YellowPinView = pinView;
                return pinView;
            }
        }
        
        return nil;
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        if YellowPinView != nil && views.contains(YellowPinView!) {
            YellowPinView?.wantsLayer = true;
            YellowPinView!.layer?.zPosition = 10;
        }
    }
    
    func highlightPoint(withIndex: CLLocationCoordinate2D, yes: Bool) {
        
        if HighlitPoint != nil {
            MapView.removeAnnotation(HighlitPoint!);
            HighlitPoint = nil;
        }
        
        if yes {
            let coord = withIndex;
            HighlitPoint = MKPointAnnotation.init();
            HighlitPoint?.coordinate = coord;
            MapView.addAnnotation(HighlitPoint!);
            
            if(!MKMapRectContainsPoint(MapView.visibleMapRect, MKMapPointForCoordinate(coord))) {
                MapView.setCenterCoordinate(coord, animated: true);
            }
        }
    }
    
    private func _pixelsToDistance(pixels: Int) -> CLLocationDistance {
        
        let px1 = CGPointMake(MapView.frame.size.width / 2, MapView.frame.size.height / 2);
        let coord1 = MapView.convertPoint(px1, toCoordinateFromView: MapView);
        let px2 = CGPointMake(px1.x + CGFloat(pixels), px1.y);
        let coord2 = MapView.convertPoint(px2, toCoordinateFromView: MapView);
        
        let point1 = MKMapPointForCoordinate(coord1);
        let point2 = MKMapPointForCoordinate(coord2);
        let distance : CLLocationDistance = MKMetersBetweenMapPoints(point1, point2);
        
        return distance;
    }
    
    func setImageBrowserZoom(zoom : Float) {
        
        ImageBrowser.setZoomValue(zoom);
    }
    
    func forwardButtonPressed() {
        
        if let newRegion = ForwardStack?.pop() {
            NavigatingWithBackOrForwardButtons = true;
            BackStack?.push(MapView.region);
            MapView.setRegion(newRegion, animated: true);
        }
    }
    
    func backButtonPressed() {
        
        if let newRegion = BackStack?.pop() {
            NavigatingWithBackOrForwardButtons = true;
            ForwardStack?.push(MapView.region);
            MapView.setRegion(newRegion, animated: true);
        }
    }
}

