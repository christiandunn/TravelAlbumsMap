//
//  CDImageView.m
//  The Photo Map
//
//  Created by Christian Dunn on 5/15/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

#import "CDImageView.h"

@implementation CDImageView

- (void)mouseDown:(NSEvent *)theEvent
{
    // see
    // http://www.cocoabuilder.com/archive/cocoa/115981-nsimageview-subclass-and-mouseup.html
    if (theEvent.type != NSLeftMouseDown) {
        [super mouseDown:theEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (theEvent.type == NSLeftMouseUp) {
        NSPoint pt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        if (NSPointInRect(pt, self.bounds)) {
            [NSApp sendAction:self.clickAction to:self.target from:self];
        }
    } else {
        // this should never be called, but...
        [super mouseUp:theEvent];
    }
}

@end
