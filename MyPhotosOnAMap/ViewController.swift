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

class ViewController: NSViewController, MKMapViewDelegate, NSGestureRecognizerDelegate, HorizontalSizeAdjusterDelegate, RectangularRegionSelectorDelegate {

    var MapView: MKMapView!
    var ProgressBar: NSProgressIndicator!
    var ImageBrowser: IKImageBrowserView!
    var SizeAdjuster : HorizontalSizeAdjuster!
    var MapVsBrowser : Double = 0.5;
    var RegionSelector : RectangularRegionSelector? = nil;
    
    var LatLons : [(CLLocationCoordinate2D, CDMediaObjectWithLocation)] = [];
    var MediaLibraryBackupLatLons : [(CLLocationCoordinate2D, CDMediaObjectWithLocation)] = [];
    var FriendsNeededToNotBeLonely : Int = Constants.MinimumPointsForCluster;
    var ClusterRadius : Double = Constants.ClusterRadius;
    var Clustering : ClusteringAlgorithm<MLMediaObject>? = nil;
    var Timing : Timer? = nil;
    var annotations : [ModifiedPinAnnotation] = [];
    var Overlays : [ModifiedClusterAnnotation] = [];
    var ImageBrowserDel : ImageBrowserDelegate? = nil;
    var verticalScroller : NSScroller? = nil;
    var HighlitPoint : MKPointAnnotation? = nil;
    var accessor : MediaLibraryAccessor? = nil;
    var MediaAccessorStatusWindow : DirectoryLoaderWindowController? = nil;
    var YellowPinView : MKPinAnnotationView? = nil;
    var scrollView : NSScrollView!;
    var LastRegionRefreshed : MKCoordinateRegion? = nil;
    var mediaAccessorAlert : NSAlert? = nil;
    
    var BackStack : CDMapRegionStack? = nil;
    var ForwardStack : CDStack<MKCoordinateRegion>? = nil;
    var LastRegion : MKCoordinateRegion? = nil;
    var NavButton : Bool = false;
    
    var DateFilterStart : NSDate;
    var DateFilterFinish : NSDate;
    var DateFilterUse : Bool = false;
    
    static var VC : ViewController?;
    
    static func getMainViewController() -> ViewController? {
        
        return VC;
    }
    
    required init?(coder: NSCoder) {
        
        DateFilterStart = Constants.DateFilterStartDefault;
        DateFilterFinish = Constants.DateFilterFinishDefault;
        super.init(coder: coder);
        initialization();
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        DateFilterStart = Constants.DateFilterStartDefault;
        DateFilterFinish = Constants.DateFilterFinishDefault;
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        initialization();
    }
    
    func initialization() {
        
        ViewController.VC = self;
    }
    
    func CGRectMake(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x:x,y:y), size:CGSize(width:w,height:h));
    }
    
    func CGPointMake(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x:x,y:y);
    }
    
    func CGSizeMake(w: CGFloat, h: CGFloat) -> CGSize {
        return CGSize(width:w,height:h);
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NSApplication.shared().mainWindow?.backgroundColor = NSColor.white;        
        Clustering = ClusteringAlgorithm<MLMediaObject>(withMaxDistance: ClusterRadius);
        
        BackStack = CDMapRegionStack.init();
        ForwardStack = CDStack<MKCoordinateRegion>.init();
        let gestureRecognizer = NSPanGestureRecognizer.init(target: self, action: #selector(userTappedMap));
        gestureRecognizer.delegate = self;
        
        ImageBrowser = IKImageBrowserView.init(frame: CGRectMake(x: 0.0, y: 0.0, w: 1.0, h: 1.0));
        ImageBrowser.setIntercellSpacing(CGSizeMake(w: 0.0, h: 0.0));
        ImageBrowser.setAllowsMultipleSelection(false);
        self.view.addSubview(ImageBrowser);
        ImageBrowserDel = ImageBrowserDelegate.init(imageBrowser: ImageBrowser, delegate: self);
        
        MapView = MKMapView.init(frame: CGRectMake(x: 0.0, y: 0.0, w: 1.0, h: 1.0));
        MapView.mapType = MKMapType.hybrid;
        MapView.showsScale = true;
        MapView.showsBuildings = true;
        MapView.showsCompass = true;
        MapView.showsZoomControls = true;
        MapView.delegate = self;
        self.view.addSubview(MapView);
        MapView.addGestureRecognizer(gestureRecognizer);
        
        scrollView = NSScrollView.init(frame: ImageBrowser.frame);
        scrollView.documentView = ImageBrowser;
        scrollView.hasVerticalScroller = true;
        self.view.addSubview(scrollView);
        
        ProgressBar = NSProgressIndicator.init(frame: CGRectMake(x: 0.0, y: 0.0, w: 100.0, h: 100.0));
        ProgressBar.style = NSProgressIndicatorStyle.spinningStyle;
        ProgressBar.isIndeterminate = true;
        ProgressBar.isDisplayedWhenStopped = true;
        ProgressBar.isHidden = true;
        self.view.addSubview(ProgressBar);
        
        SizeAdjuster = HorizontalSizeAdjuster.init(frame: CGRectMake(x: 0.0, y: 0.0, w: 1.0, h: 100.0));
        SizeAdjuster.Delegate = self;
        self.view.addSubview(SizeAdjuster);
        MapVsBrowser = Constants.MapViewFraction;
    }
    
    override func viewDidLayout() {
        
        super.viewDidLayout();
        
        let width = self.view.frame.size.width;
        let height = self.view.frame.size.height;
        
        MapView.setFrameSize(CGSizeMake(w: CGFloat(Double(width)*MapVsBrowser), h: height));
        scrollView.setFrameOrigin(CGPointMake(x: width*CGFloat(MapVsBrowser), y: 0.0));
        scrollView.setFrameSize(CGSizeMake(w: width*CGFloat(1-MapVsBrowser), h: height));
        ProgressBar.setFrameOrigin(CGPointMake(x: MapView.frame.size.width/2 - 50.0, y: MapView.frame.size.height/2 - 50.0));
        SizeAdjuster.setFrameSize(CGSizeMake(w: CGFloat(Constants.SizeAdjusterWidth), h: height));
        SizeAdjuster.setFrameOrigin(CGPointMake(x: width*CGFloat(MapVsBrowser)-CGFloat(Constants.SizeAdjusterWidth)/2, y: 0.0));
        
        if RegionSelector != nil {
            RegionSelector?.frame = MapView.frame;
        }
    }
    
    func loadMapWithFilePaths(mediaObjects: [CDMediaObjectWithLocation]) {
        
        let mediaObjectsWithLocation = mediaObjects.filter {$0.Location != nil};
        LatLons = mediaObjectsWithLocation.map {($0.Location!, $0)};
        refreshPoints();
    }
    
    func loadMapWithLibrary() {
        
        if MediaLibraryBackupLatLons.count == 0 {
            ProgressBar.isHidden = false;
            ProgressBar.startAnimation(self);
            if accessor == nil {
                accessor = MediaLibraryAccessor();
            } else {
                accessor?.removeObserverFromMediaLibrary();
            }
            accessor!.setDelegate(self, withSelector: "mediaAccessorDidFinishLoadingAlbums");
            accessor!.setStatusReportSelector("mediaAccessorDidReportStatus");
            
            let storyboard : NSStoryboard = NSStoryboard.init(name: "Main", bundle: nil);
            MediaAccessorStatusWindow = storyboard.instantiateController(withIdentifier: "DateFilterWindowController") as? DirectoryLoaderWindowController;
            MediaAccessorStatusWindow?.showWindow(nil);
            MediaAccessorStatusWindow?.VC?.setViewController(vc: self);
            
            accessor!.initialize();
        } else {
            LatLons = MediaLibraryBackupLatLons;
            addPoints(points: LatLons);
        }
    }
    
    func mediaAccessorDidReportStatus() {
        
        if accessor == nil {
            return;
        }
        let status = accessor!.statusMessage;
        MediaAccessorStatusWindow!.VC?.updateLabel(labelText: status!);
    }
    
    func mediaAccessorDidFinishLoadingAlbums() {
        
        ProgressBar.isHidden = true;
        MediaAccessorStatusWindow?.close();
        
        if accessor!.errorState {
            accessor?.getMediaObjects().removeAllObjects();
            self.mediaAccessorErrorPrompt();
            return;
        }        
        
        let mediaObjects: Array<MLMediaObject> = accessor!.getMediaObjects() as NSArray as! [MLMediaObject];
        if mediaObjects.count == 0 {
            self.mediaAccessorErrorPrompt();
        }
        
        let attributes = mediaObjects.map {($0.attributes, $0)}.filter {$0.0.index(forKey: "latitude") != nil}.filter {$0.0.index(forKey: "longitude") != nil};
        let latLons = attributes.map {(CLLocationCoordinate2DMake($0.0["latitude"] as! Double, $0.0["longitude"] as! Double), CDMediaObjectFactory.createFromMlMediaObject(withObject: $0.1))};
        LatLons = latLons;
        MediaLibraryBackupLatLons = LatLons;
        addPoints(points: LatLons);
    }
    
    func mediaAccessorStop() {
        
        accessor?.reportErrorFindingMedia();
    }
    
    func mediaAccessorErrorPrompt() {
        
        if mediaAccessorAlert == nil {
            
            mediaAccessorAlert = NSAlert.init();
            mediaAccessorAlert!.messageText = (accessor?.getErrorLoadingPhotosMessage())!;
            mediaAccessorAlert!.addButton(withTitle: "Close");
            mediaAccessorAlert!.addButton(withTitle: "Find Photo Library File");
            mediaAccessorAlert!.addButton(withTitle: "Load Folder");
            let response = mediaAccessorAlert!.runModal();
            
            if response == NSAlertSecondButtonReturn {
                let itemLoader : ItemsInDirectoryLoader = ItemsInDirectoryLoader.init(withViewController: self);
                itemLoader.loadPhotoLibrary();
            }
            
            if response == NSAlertThirdButtonReturn {
                let itemLoader : ItemsInDirectoryLoader = ItemsInDirectoryLoader.init(withViewController: self);
                itemLoader.loadItemsFromDirectory();
            }
            
            mediaAccessorAlert = nil;
        }
    }
    
    func userTappedMap(gestureRecognizer : NSGestureRecognizer) {
        
        if gestureRecognizer.state == NSGestureRecognizerState.ended {
            self.userInitiatedMapChangeDidHappen();
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer) -> Bool {
        return true;
    }
    
    func userInitiatedMapChangeDidHappen() {
        
        ForwardStack?.removeAll();
    }
    
    func setTimerForPointsRefresh() {
        
        if Timing != nil {
            Timing?.invalidate();
            Timing = nil;
        }
        Timing = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(refreshPoints), userInfo: nil, repeats: false);
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        if LastRegion != nil && !NavButton {
            BackStack?.push(element: LastRegion!);
        }
        LastRegion = mapView.region;
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if LatLons.count > 0 && (LastRegionRefreshed == nil || !CDMapRegionStack.regionsAreSimilarIntolerant(region1: LastRegionRefreshed!, region2: mapView.region)) {
            
            self.setTimerForPointsRefresh();
        }
        NavButton = false;
    }
    
    @objc private func refreshPoints() {
        
        _removeAllCoordsFromMap();
        addPoints(points: LatLons);
        LastRegionRefreshed = MapView.region;
    }

    private func addPoints(points: [(CLLocationCoordinate2D, CDMediaObjectWithLocation)]) {
        //print("Points Count " + String(points.count));
        let mapViewPoints = points.map
            {(MapView.convert($0.0, toPointTo: MapView), $0.1)}.filter
            {MapView.frame.contains($0.0)}.filter
            {!DateFilterUse || ($0.1.Date.isLessThanDate(dateToCompare: DateFilterFinish) && $0.1.Date.isGreaterThan(DateFilterStart))}
        let mapViewCGPoints = mapViewPoints.map {$0.0};
        if mapViewPoints.count == 0 {
            return;
        }
        ProgressBar.isHidden = false;
        ProgressBar.startAnimation(self);
        
        let lonelyPoints = mapViewPoints.filter {_countClosePoints(point: $0.0, points: mapViewCGPoints) < FriendsNeededToNotBeLonely};
        let lonelyCoords = lonelyPoints.map {(MapView.convert($0.0, toCoordinateFrom: MapView), $0.1)};
        _addLonelyCoordsToMap(coords: lonelyCoords);
        
        let friendlyPoints = mapViewPoints.filter {_countClosePoints(point: $0.0, points: mapViewCGPoints) >= FriendsNeededToNotBeLonely};
        if friendlyPoints.count == 0 {
            ProgressBar.isHidden = true;
            return;
        }
        let (clusterCenters, maxD, clusterCounts, clusters) = Clustering!.kMeans(points: friendlyPoints);
        let clusterCoords = clusterCenters.map {(MapView.convert($0.0, toCoordinateFrom: MapView), $0.1)};
        let clustersOfCoords = clusters.map({(c : Cluster) -> ClusterOfCoordinates in _convertClustersToCoordinate(cluster: c)});
        _addClusterCoordsToMap(coords: clusterCoords, maxDs: maxD, clusterCounts: clusterCounts, clusters: clustersOfCoords);
        ProgressBar.isHidden = true;
    }
    
    private func _convertClustersToCoordinate(cluster : Cluster) -> ClusterOfCoordinates {
        
        let center = MapView.convert(cluster.Center, toCoordinateFrom: MapView);
        let points = cluster.Points.map({MapView.convert($0, toCoordinateFrom: MapView)});
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
            let distance = _pointDistance(point: point, pt: pt);
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
        
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        view.setSelected(true, animated: true);
        let annotation = view.annotation;        
        _processAnnotation(annotation: annotation!);
    }
    
    func _processAnnotation(annotation : MKAnnotation) {
        
        if (annotation as? ModifiedPinAnnotation) != nil {
            _processPhotoDataAnnotation(annotation: annotation);
        }
        
        if (annotation as? ModifiedClusterAnnotation) != nil {
            _processPhotoDataAnnotation(annotation: annotation);
        }
    }
    
    private func _processPhotoDataAnnotation(annotation: MKAnnotation) {
        
        let newRegion = ImageBrowserDel?.activateAnnotationView(annotation: annotation);
        
        if newRegion != nil {
            MapView.setRegion(newRegion!, animated: true);
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let anno = annotation as? ModifiedPinAnnotation {
            let pinView = MKPinAnnotationView.init(annotation: anno, reuseIdentifier: "\(anno.coordinate.latitude), \(anno.coordinate.longitude)");
            pinView.pinTintColor = NSColor.red;
            pinView.animatesDrop = false;
            return pinView;
        }
        
        if let anno = annotation as? ModifiedClusterAnnotation {
            let pinView = MKPinAnnotationView.init(annotation: anno, reuseIdentifier: "\(anno.coordinate.latitude), \(anno.coordinate.longitude)");
            pinView.pinTintColor = NSColor.blue;
            pinView.animatesDrop = false;
            return pinView;
        }
        
        if let anno = annotation as? MKPointAnnotation {
            if anno == HighlitPoint {
                let pinView = MKPinAnnotationView.init(annotation: anno, reuseIdentifier: "\(anno.coordinate.latitude), \(anno.coordinate.longitude)");
                pinView.pinTintColor = NSColor.yellow;
                YellowPinView = pinView;
                return pinView;
            }
        }
        
        return nil;
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
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
                MapView.setCenter(coord, animated: true);
            }
        }
    }
    
    private func _pixelsToDistance(pixels: Int) -> CLLocationDistance {
        
        let px1 = CGPointMake(x: MapView.frame.size.width / 2, y: MapView.frame.size.height / 2);
        let coord1 = MapView.convert(px1, toCoordinateFrom: MapView);
        let px2 = CGPointMake(x: px1.x + CGFloat(pixels), y: px1.y);
        let coord2 = MapView.convert(px2, toCoordinateFrom: MapView);
        
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
            BackStack?.push(element: MapView.region);
            NavButton = true;
            MapView.setRegion(newRegion, animated: true);
        }
    }
    
    func backButtonPressed() {
        
        if let newRegion = BackStack?.pop() {
            ForwardStack?.push(element: MapView.region);
            NavButton = true;
            MapView.setRegion(newRegion, animated: true);
            LastRegion = nil;
        }
    }
    
    func exportToCsv(path : NSURL, instructions : SaveDialogService.SaveCsvInstructions) {
        
        var objects : [CDMediaObjectWithLocation] = [];
        if instructions == SaveDialogService.SaveCsvInstructions.SaveAll {
            objects = LatLons.map {$0.1};
        }
        if instructions == SaveDialogService.SaveCsvInstructions.SaveVisible {
            let mapViewPoints = LatLons.map {(MapView.convert($0.0, toPointTo: MapView), $0.1)}.filter {MapView.frame.contains($0.0)};
            objects = mapViewPoints.map {$0.1};
        }
        objects = objects.filter {!DateFilterUse || ($0.Date.isLessThanDate(dateToCompare: DateFilterFinish) && $0.Date.isGreaterThan(DateFilterStart))};
        
        let exporter = CDCsvExporter.init(withPath: path, andItems: objects);
        let result = exporter.export();
        let resultText = result ? "The CSV file has been saved." : "There was a problem saving the CSV file."
        let alert = NSAlert.init();
        alert.messageText = resultText;
        alert.runModal();
    }
    
    func updateDateFilter(withEarliestDate earliest : NSDate, andFuturemostDate latest : NSDate, useDateFilter : Bool) {
        
        DateFilterStart = earliest;
        DateFilterFinish = latest;
        DateFilterUse = useDateFilter;
        refreshPoints();
    }
    
    func horizontalSizeAdjusterWasMoved(deltaX: CGFloat) {
        let width = Double(self.view.frame.size.width);
        MapVsBrowser = min(max(MapVsBrowser + Double(deltaX) / width, 0.25), 0.75);
        self.viewDidLayout();
    }
    
    func mouseUp() {
        self.setTimerForPointsRefresh();
    }
    
    func selectPointsInit() {
        
        if RegionSelector != nil {
            RegionSelector?.removeFromSuperview();
            RegionSelector = nil;
        }
        RegionSelector = RectangularRegionSelector.init(frame: MapView.frame);
        RegionSelector!.Delegate = self;
        self.view.addSubview(RegionSelector!);
    }
    
    func rectangularRegionWasSelected(region: CGRect) {
        
        RegionSelector?.removeFromSuperview();
        RegionSelector = nil;
        
        let mapViewPoints = LatLons.map
            {(MapView.convert($0.0, toPointTo: MapView), $0.1)}.filter
            {region.contains($0.0)}
        if mapViewPoints.count == 0 {
            return;
        }
        let cdMediaObjects = mapViewPoints.map({(pt) -> CDMediaObjectWithLocation in
            return pt.1;
        });
        let coords = cdMediaObjects.map({mediaObject in return mediaObject.Location!});
        
        let cluster = ClusterOfCoordinates.init(withPoints: coords);
        let adHocDataLoad = MapAnnotation.init(withMediaObjects: mapViewPoints.map {$0.1}, andCluster: cluster);
        let adHocClusterAnnotation = ModifiedClusterAnnotation.init(withDataLoad: adHocDataLoad);
        self._processAnnotation(annotation: adHocClusterAnnotation);
    }
}

