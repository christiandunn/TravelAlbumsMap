//
//  HorizontalSizeAdjuster.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/21/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public protocol HorizontalSizeAdjusterDelegate {
    
    func horizontalSizeAdjusterWasMoved(deltaX: CGFloat);
    func mouseUp();
}

public class HorizontalSizeAdjuster : NSView {
    
    var TrackingArea : NSTrackingArea? = nil;
    public var Delegate : HorizontalSizeAdjusterDelegate? = nil;
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect);
    }
    
    public required init?(coder: NSCoder) {
        
        super.init(coder: coder);
        self.wantsLayer = true;
        self.layer!.backgroundColor = NSColor.yellowColor().CGColor;
        
    }
    
    override public func mouseEntered(theEvent: NSEvent) {
        let cursor = NSCursor.resizeLeftRightCursor();
        cursor.setOnMouseEntered(true);
        cursor.mouseEntered(theEvent);
    }
    
    override public func mouseExited(theEvent: NSEvent) {
        let cursor = NSCursor.arrowCursor();
        cursor.setOnMouseExited(true);
        cursor.mouseExited(theEvent);
    }
    
    override public func mouseDragged(theEvent: NSEvent) {
        Delegate?.horizontalSizeAdjusterWasMoved(theEvent.deltaX);
    }
    
    override public func mouseUp(theEvent: NSEvent) {
        Delegate?.mouseUp();
    }
    
    public override func updateTrackingAreas() {
        if TrackingArea != nil {
            self.removeTrackingArea(TrackingArea!);
            TrackingArea = nil;
        }
        let opts = NSTrackingAreaOptions.MouseEnteredAndExited.union(NSTrackingAreaOptions.ActiveAlways);
        TrackingArea = NSTrackingArea.init(rect: self.bounds, options: opts, owner: self, userInfo: nil);
        self.addTrackingArea(TrackingArea!);
    }
}
