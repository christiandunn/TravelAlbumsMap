//
//  MediaLibraryAccessor.m
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 4/19/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//
//  Includes works derived from source code at http://stackoverflow.com/questions/30144547/programmatic-access-to-the-photos-library-on-mac-os-x-photokit-photos-framewo
//

#import "MediaLibraryAccessor.h"

@implementation MediaLibraryAccessor

@synthesize ErrorState;
@synthesize ErrorMessage;

- (void)initialize {
    
    Finished = FALSE;
    ErrorState = FALSE;
    ErrorMessage = @"";
    KVO_Observers = [[NSMutableArray alloc] initWithCapacity:100];
    MediaObjects = [NSMutableArray arrayWithCapacity:1000];
    
    NSDictionary *options = @{
                              MLMediaLoadSourceTypesKey: @(MLMediaSourceTypeImage),
                              MLMediaLoadIncludeSourcesKey: @[MLMediaSourcePhotosIdentifier]
                              };
    
    self.mediaLibrary = [[MLMediaLibrary alloc] initWithOptions:options];
    
    MediaObjectsLoadedMessenger *firstMessage = [MediaObjectsLoadedMessenger new];
    firstMessage.Message = MediaLibraryLoaded;
    CFBridgingRetain(firstMessage);
    [self.mediaLibrary addObserver:self
                        forKeyPath:@"mediaSources"
                           options:0
                           context:(__bridge void *)firstMessage];
    KVO_Observer *observer = [[KVO_Observer alloc] initWithObservee:self.mediaLibrary andKeyPath:@"mediaSources" andObserver:self];
    [KVO_Observers addObject:observer];
    [self.mediaLibrary.mediaSources objectForKey:MLMediaSourcePhotosIdentifier];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    MediaObjectsLoadedMessenger *messageContainer = (__bridge MediaObjectsLoadedMessenger *)context;
    MediaLoadingMessage message = messageContainer.Message;
    MLMediaSource *mediaSource = [self.mediaLibrary.mediaSources objectForKey:MLMediaSourcePhotosIdentifier];
    if (mediaSource == nil) {
        [self reportErrorFindingMedia];
        return;
    }
    
    if (message == MediaLibraryLoaded)
    {
        MediaObjectsLoadedMessenger *msg = [MediaObjectsLoadedMessenger new];
        msg.Message = RootMediaGroupLoaded;
        CFBridgingRetain(msg);
        [mediaSource addObserver:self
                      forKeyPath:@"rootMediaGroup"
                         options:0
                         context:(__bridge void *)msg];
        KVO_Observer *observer = [[KVO_Observer alloc] initWithObservee:mediaSource andKeyPath:@"rootMediaGroup" andObserver:self];
        [KVO_Observers addObject:observer];
        [mediaSource rootMediaGroup];
    }
    else if (message == RootMediaGroupLoaded)
    {
        albums = [mediaSource mediaGroupForIdentifier:@"TopLevelAlbums"];
        bool useAllPhotosAlbum = true;
        if (albums.childGroups.count == 0) {
            albums = nil;
        }
        
        if (albums == nil) {
            albums = [mediaSource mediaGroupForIdentifier:@"AllMomentsGroup"];
            useAllPhotosAlbum = false;
            if (albums.childGroups.count == 0) {
                albums = nil;
            }
        }
        
        if (albums == nil) {
            albums = [mediaSource mediaGroupForIdentifier:@"AllCollectionsGroup"];
            useAllPhotosAlbum = false;
            if (albums.childGroups.count == 0) {
                albums = nil;
            }
        }
        
        if (albums == nil) {
            albums = [mediaSource mediaGroupForIdentifier:@"AllYearsGroup"];
            useAllPhotosAlbum = false;
            if (albums.childGroups.count == 0) {
                albums = nil;
            }
        }
        
        /* This one is a recursively layered media group that has location info in it */
        //        if (albums == nil) {
        //            albums = [mediaSource mediaGroupForIdentifier:@"allPlacedPhotosAlbum"];
        //            useAllPhotosAlbum = false;
        //            if (albums.childGroups.count == 0) {
        //                albums = nil;
        //            }
        //        }
        
        if (albums == nil) {
            [self reportErrorFindingMedia];
        }
        
        AlbumsToLoad = 0;
        AlbumsLoaded = 0;
        
        for (MLMediaGroup *album in albums.childGroups)
        {
            NSString *albumIdentifier = [album.attributes objectForKey:@"identifier"];
            AlbumsToLoad++;
            
            if (!useAllPhotosAlbum || (useAllPhotosAlbum && [albumIdentifier isEqualTo:@"allPhotosAlbum"]))
            {
                MediaObjectsLoadedMessenger *msg = [MediaObjectsLoadedMessenger new];
                msg.Message = MediaObjectsLoaded;
                msg.MediaGroup = album;
                CFBridgingRetain(msg);
                
                [album addObserver:self
                        forKeyPath:@"mediaObjects"
                           options:0
                           context:(__bridge void *)msg];
                KVO_Observer *observer = [[KVO_Observer alloc] initWithObservee:album andKeyPath:@"mediaObjects" andObserver:self];
                [KVO_Observers addObject:observer];
                [album mediaObjects];
                
                if (useAllPhotosAlbum) {
                    break;
                }
            }
        }
    }
    else if (message == SubMediaGroupLoaded)
    {
        NSLog(@"Sub-Media Group Loaded");
    }
    else if (message == MediaObjectsLoaded)
    {
        NSArray * mediaObjects = messageContainer.MediaGroup.mediaObjects;
        
        for (MLMediaObject * mediaObject in mediaObjects)
        {
            [MediaObjects addObject:mediaObject];
        }
        
        AlbumsLoaded++;
        if (AlbumsLoaded >= AlbumsToLoad) {
            
            Finished = TRUE;
            [self callDelegateAndExit];
        }
    }
    
    CFBridgingRelease(context);
}

- (void)callDelegateAndExit {
    
    //Remove observer from the media library
    [self removeObserverFromMediaLibrary];
    
    if (!Delegate) { return; }
    SEL selector = NSSelectorFromString(Selector);
    IMP imp = [Delegate methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(Delegate, selector);
}

- (void)removeObserverFromMediaLibrary {
    
    for (KVO_Observer * observer in KVO_Observers) {
        id observee = observer.Observee;
        id Observer = observer.Observer;
        NSString *keyPath = observer.KeyPath;
        [observee removeObserver:Observer forKeyPath:keyPath];
    }
    [KVO_Observers removeAllObjects];
}

- (void)reportErrorFindingMedia {
    
    ErrorState = YES;
    ErrorMessage = @"Unable to load photos from the main photo library. Please ensure the library exists and you can access it on this computer if you would like to be able to load it here.";
    [self callDelegateAndExit];
}

- (void)setDelegate:(id)del withSelector:(NSString *)sel {
    
    Delegate = del;
    Selector = sel;
}

- (NSMutableArray *)getMediaObjects {
    
    return MediaObjects;
}

+ (NSDictionary *)getImagePropertiesDictionary:(NSURL *)path {
    
    CFURLRef url = (__bridge CFURLRef)path;
    CGImageSourceRef myImageSource;
    myImageSource = CGImageSourceCreateWithURL(url, NULL);
    if (myImageSource == nil) {
        return [[NSDictionary alloc] init];
    }
    CFDictionaryRef imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(myImageSource, 0, NULL);
    NSDictionary *imageDict = (__bridge NSDictionary *)imagePropertiesDictionary;
    
    return imageDict;
}

+ (NSString *)getExifDateTimeOriginal:(NSURL *)path {
    
    NSDictionary *imageDict = [MediaLibraryAccessor getImagePropertiesDictionary:path];
    NSDictionary *dictionary = [imageDict valueForKey:@"{Exif}"];
    NSString *result = [dictionary valueForKey:@"DateTimeOriginal"];
    
    return result;
}

+ (NSNumber *)getGpsAltitude:(NSURL *)path {
    
    NSDictionary *imageDict = [MediaLibraryAccessor getImagePropertiesDictionary:path];
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    NSNumber *result = (NSNumber *)[dictionary valueForKey:@"Altitude"];
    
    return result;
}

+ (NSNumber *)getGpsSpeed:(NSURL *)path {
    
    NSDictionary *imageDict = [MediaLibraryAccessor getImagePropertiesDictionary:path];
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    NSNumber *result = (NSNumber *)[dictionary valueForKey:@"Speed"];
    
    return result;
}

+ (CLLocationCoordinate2D)getLocation:(NSURL *)path {
    
    NSDictionary *imageDict = [MediaLibraryAccessor getImagePropertiesDictionary:path];
    NSDictionary *dictionary = [imageDict valueForKey:@"{GPS}"];
    NSNumber *latitude = (NSNumber *)[dictionary valueForKey:@"Latitude"];
    NSNumber *longitude = (NSNumber *)[dictionary valueForKey:@"Longitude"];
    NSString *latitudeRef = (NSString *)[dictionary valueForKey:@"LatitudeRef"];
    NSString *longitudeRef = (NSString *)[dictionary valueForKey:@"LongitudeRef"];
    double lat = latitude.doubleValue * ([latitudeRef compare:@"S"] == NSOrderedSame ? -1 : 1);
    double lon = longitude.doubleValue * ([longitudeRef compare:@"W"] == NSOrderedSame ? -1 : 1);
    return CLLocationCoordinate2DMake(lat, lon);
}

@end

@implementation MediaObjectsLoadedMessenger

@synthesize MediaGroup;
@synthesize Message;

@end

@implementation KVO_Observer

@synthesize Observee;
@synthesize Observer;
@synthesize KeyPath;

- (id)initWithObservee:(id)observee andKeyPath:(NSString *)keyPath andObserver:(id)observer {
    
    self = [super init];
    self.Observee = observee;
    self.Observer = observer;
    self.KeyPath = keyPath;
    return self;
}

@end
