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
    var CursorSaver : NSCursor? = nil;
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect);
    }
    
    public required init?(coder: NSCoder) {
        
        super.init(coder: coder);
    }
    
    override public func mouseDragged(with theEvent: NSEvent) {
        Delegate?.horizontalSizeAdjusterWasMoved(deltaX: theEvent.deltaX);
    }
    
    override public func mouseUp(with theEvent: NSEvent) {
        Delegate?.mouseUp();
    }
    
    override public func mouseDown(with theEvent: NSEvent) {
        
    }
    
    public override func resetCursorRects() {
        let cursor = NSCursor.resizeLeftRight()
        self.addCursorRect(self.bounds, cursor: cursor);
        cursor.setOnMouseEntered(true);
    }
}
