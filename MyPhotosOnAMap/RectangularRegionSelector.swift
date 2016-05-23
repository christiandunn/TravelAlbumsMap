//
//  RectangularRegionSelector.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/22/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public protocol RectangularRegionSelectorDelegate {
    
    func rectangularRegionWasSelected(region : CGRect);
}

public class RectangularRegionSelector : NSView {
    
    public var Delegate : RectangularRegionSelectorDelegate? = nil;
    private var Region : CGRect? = nil;
    private var StartX : CGFloat = 0.0;
    private var StartY : CGFloat = 0.0;
    private var DeltaX : CGFloat = 0.0;
    private var DeltaY : CGFloat = 0.0;
    public var CursorSaver : NSCursor? = nil;
    var TrackingArea : NSTrackingArea? = nil;
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect);
    }
    
    public required init?(coder: NSCoder) {
        
        super.init(coder: coder);
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        
        let loc = theEvent.locationInWindow;
        let pt = self.convertPoint(loc, fromView: nil);
        StartX = pt.x;
        StartY = pt.y;
        Region = CGRectMake(StartX, StartY, 0.0, 0.0);
    }
    
    override public func mouseDragged(theEvent: NSEvent) {
        
        if Region == nil {
            return;
        }
        let deltaX = theEvent.deltaX;
        let deltaY = theEvent.deltaY;
        DeltaX = DeltaX + deltaX;
        DeltaY = DeltaY + deltaY;
        Region!.origin.x = StartX + (DeltaX < 0 ? DeltaX : 0);
        Region!.origin.y = StartY - (DeltaY > 0 ? DeltaY : 0);
        Region!.size.width = fabs(DeltaX);
        Region!.size.height = fabs(DeltaY);
        self.setNeedsDisplayInRect(self.bounds);
    }
    
    override public func mouseUp(theEvent: NSEvent) {
        
        if Region == nil {
            return;
        }
        Region!.origin.y = self.frame.size.height - Region!.origin.y - Region!.size.height;
        exitThis();
    }
    
    private func exitThis() {
        
        let cursor = CursorSaver != nil ? CursorSaver! : NSCursor.arrowCursor();
        cursor.set();
        Delegate?.rectangularRegionWasSelected(Region!);
        Region = nil;
    }
    
    override public func drawRect(dirtyRect: NSRect) {
        
        if Region == nil {
            return;
        }
        NSColor.redColor().set();
        let figure = NSBezierPath.init(roundedRect: Region!, xRadius: 0.0, yRadius: 0.0);
        let pattern : [CGFloat] = [5.0, 5.0];
        figure.lineWidth = 2.0;
        figure.setLineDash(pattern, count: 2, phase: 0.0);
        figure.stroke();
    }
    
    public override func resetCursorRects() {
        let cursor = NSCursor.crosshairCursor();
        self.addCursorRect(self.bounds, cursor: cursor);
        cursor.setOnMouseEntered(true);
    }
}
