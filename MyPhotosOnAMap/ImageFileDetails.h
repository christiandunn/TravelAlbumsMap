//
//  ImageFileDetails.h
//  The Photo Map
//
//  Created by Christian Dunn on 5/21/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ImageFileDetails : NSObject {
    
    NSURL *path;
    CFDictionaryRef dictionaryRef;
}

- (id)initWithPath:(NSURL *)_path;

- (CFDictionaryRef)getImagePropertiesDictionary;
- (NSString *)getExifDateTimeOriginal;
- (bool)containsGpsMetadata;
- (NSNumber *)getGpsAltitude;
- (NSNumber *)getGpsSpeed;
- (CLLocationCoordinate2D)getLocation;

@end
