//
//  ImageFileDetails.m
//  The Photo Map
//
//  Created by Christian Dunn on 5/21/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

#import "ImageFileDetails.h"

@implementation ImageFileDetails

- (id)initWithPath:(NSURL *)_path {
    self = [super init];
    path = _path;
    dictionaryRef = [self getImagePropertiesDictionary];
    CFRetain(dictionaryRef);
    return self;
}

- (CFDictionaryRef)getImagePropertiesDictionary {
    
    CFURLRef url = (__bridge CFURLRef)path;
    
    myImageSource = CGImageSourceCreateWithURL(url, NULL);
    if (myImageSource == nil) {
        return (__bridge CFDictionaryRef)([[NSDictionary alloc] init]);
    }
    CFDictionaryRef imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(myImageSource, 0, NULL);
    return imagePropertiesDictionary;
}

- (NSString *)getExifDateTimeOriginal {
    
    NSDictionary *imageDict = (__bridge NSDictionary *)(dictionaryRef);
    NSDictionary *dictionary = [imageDict valueForKey:@"{Exif}"];
    NSString *result = [[dictionary valueForKey:@"DateTimeOriginal"] copy];
    CFBridgingRelease(dictionaryRef);
    CFBridgingRelease((__bridge CFTypeRef _Nullable)(dictionary));
    return result;
}

- (NSNumber *)getGpsAltitude {
    
    NSDictionary *imageDict = (__bridge NSDictionary *)(dictionaryRef);
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    NSNumber *result = (NSNumber *)[dictionary valueForKey:@"Altitude"];
    CFBridgingRelease(dictionaryRef);
    CFBridgingRelease((__bridge CFTypeRef _Nullable)(dictionary));
    return result;
}

- (NSNumber *)getGpsSpeed {
    
    NSDictionary *imageDict = (__bridge NSDictionary *)(dictionaryRef);
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    NSNumber *result = (NSNumber *)[dictionary valueForKey:@"Speed"];
    CFBridgingRelease(dictionaryRef);
    CFBridgingRelease((__bridge CFTypeRef _Nullable)(dictionary));
    return result;
}

- (CLLocationCoordinate2D)getLocation {
    
    NSDictionary *imageDict = (__bridge NSDictionary *)(dictionaryRef);
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    NSNumber *latitude = (NSNumber *)[dictionary valueForKey:@"Latitude"];
    NSNumber *longitude = (NSNumber *)[dictionary valueForKey:@"Longitude"];
    NSString *latitudeRef = (NSString *)[dictionary valueForKey:@"LatitudeRef"];
    NSString *longitudeRef = (NSString *)[dictionary valueForKey:@"LongitudeRef"];
    double lat = latitude.doubleValue * ([latitudeRef compare:@"S"] == NSOrderedSame ? -1 : 1);
    double lon = longitude.doubleValue * ([longitudeRef compare:@"W"] == NSOrderedSame ? -1 : 1);
    CFBridgingRelease(dictionaryRef);
    CFBridgingRelease((__bridge CFTypeRef _Nullable)(dictionary));
    return CLLocationCoordinate2DMake(lat, lon);
}

@end
