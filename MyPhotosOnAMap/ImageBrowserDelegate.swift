//
//  ImageBrowserDelegate.swift
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 5/9/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation
import Quartz
import MapKit

public class ImageBrowserDelegate {
    
    var ImageBrowser : IKImageBrowserView;
    var CurrentAnno : ModifiedAnnotation? = nil;
    var SelectionSet : NSIndexSet? = nil;
    var Delegate : ViewController;
    
    init(imageBrowser : IKImageBrowserView, delegate : ViewController) {
        
        Delegate = delegate;
        
        ImageBrowser = imageBrowser;
        ImageBrowser.setDataSource(self);
        ImageBrowser.setCellsStyleMask(IKCellsStyleTitled + IKCellsStyleSubtitled);        
        
        NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(step), userInfo: nil, repeats: true);
    }
    
    @objc private func step() {
        
        let newSelectionSet = ImageBrowser.selectionIndexes() ?? nil;
        
        if newSelectionSet != nil && newSelectionSet!.count == 0 {
            Delegate.highlightPoint(CLLocationCoordinate2DMake(0.0, 0.0), yes: false);
        }
        
        if newSelectionSet != nil && newSelectionSet!.count > 0 {
            if newSelectionSet!.firstIndex != (SelectionSet?.firstIndex ?? -1) {
                let index = newSelectionSet!.firstIndex;
                Delegate.highlightPoint(CLLocationCoordinate2DMake(0.0, 0.0), yes: false);
                Delegate.highlightPoint((CurrentAnno?.DataLoad.Coords[index])!, yes: true);
            }
        }
        
        SelectionSet = newSelectionSet;
    }
    
    @objc public func numberOfItemsInImageBrowser(aBrowser: IKImageBrowserView!) -> Int {
        
        return CurrentAnno?.DataLoad.Objects.count ?? 0;
    }
    
    @objc public func imageBrowser(aBrowser: IKImageBrowserView!, itemAtIndex index: Int) -> AnyObject! {
        
        let mediaObject = CurrentAnno?.DataLoad.Objects[index] ?? nil;
        
        if mediaObject == nil {
            return nil;
        }
        
        return ImageRep(imageRepWithMediaObject: mediaObject!);
    }
    
    public func activateAnnotationView(view : MKAnnotationView) -> MKCoordinateRegion? {
        
        let annotation = view.annotation;
        view.setSelected(true, animated: true);
        
        if let anno = annotation as? ModifiedPinAnnotation {
            CurrentAnno = anno;
            ImageBrowser.reloadData();
            
            return nil;
        }
        
        if let anno = annotation as? ModifiedClusterAnnotation {
            CurrentAnno = anno;
            ImageBrowser.reloadData();
            
            return anno.enclosingRegion();
        }
        
        return nil;
    }
}