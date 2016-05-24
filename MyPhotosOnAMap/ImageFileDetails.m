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
    return self;
}

- (CFDictionaryRef)getImagePropertiesDictionary {
    
    CFURLRef url = (__bridge CFURLRef)path;
    
    CGImageSourceRef myImageSource = CGImageSourceCreateWithURL(url, NULL);
    if (myImageSource == nil) {
        return (__bridge CFDictionaryRef)([[NSDictionary alloc] init]);
    }
    CFDictionaryRef imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(myImageSource, 0, NULL);
    if (myImageSource != nil) {
        CFRelease(myImageSource);
    }
    return imagePropertiesDictionary;
}

- (NSString *)getExifDateTimeOriginal {
    
    if (dictionaryRef == nil) {
        return @"";
    }
    NSDictionary *imageDict = (__bridge NSDictionary *)(dictionaryRef);
    NSDictionary *dictionary = [imageDict valueForKey:@"{Exif}"];
    NSString *result = [dictionary valueForKey:@"DateTimeOriginal"];
    return result;
}

- (bool)containsGpsMetadata {
    
    if (dictionaryRef == nil) {
        return false;
    }
    NSDictionary *imageDict = (__bridge NSDictionary *)(dictionaryRef);
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    return dictionary != nil;
}

- (NSNumber *)getGpsAltitude {
    
    if (dictionaryRef == nil) {
        return nil;
    }
    NSDictionary *imageDict = (__bridge NSDictionary *)(dictionaryRef);
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    NSNumber *result = (NSNumber *)[dictionary valueForKey:@"Altitude"];
    return result;
}

- (NSNumber *)getGpsSpeed {
    
    if (dictionaryRef == nil) {
        return nil;
    }
    NSDictionary *imageDict = (__bridge NSDictionary *)(dictionaryRef);
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    NSNumber *result = (NSNumber *)[dictionary valueForKey:@"Speed"];
    return result;
}

- (CLLocationCoordinate2D)getLocation {
    
    if (dictionaryRef == nil) {
        return CLLocationCoordinate2DMake(0.0, 0.0);
    }
    NSDictionary *imageDict = (__bridge NSDictionary *)(dictionaryRef);
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    NSNumber *latitude = (NSNumber *)[dictionary valueForKey:@"Latitude"];
    NSNumber *longitude = (NSNumber *)[dictionary valueForKey:@"Longitude"];
    NSString *latitudeRef = (NSString *)[dictionary valueForKey:@"LatitudeRef"];
    NSString *longitudeRef = (NSString *)[dictionary valueForKey:@"LongitudeRef"];
    double lat = latitude.doubleValue * ([latitudeRef compare:@"S"] == NSOrderedSame ? -1 : 1);
    double lon = longitude.doubleValue * ([longitudeRef compare:@"W"] == NSOrderedSame ? -1 : 1);
    return CLLocationCoordinate2DMake(lat, lon);
}

- (void)dealloc {
    
    if (dictionaryRef != nil) {
        CFRelease(dictionaryRef);
    }
}

@end
