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
@synthesize StatusMessage;

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
    [self reportStatus:@"Attempting to load system root media library..."];
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
    bool validMessage = false;
    
    if (message == MediaLibraryLoaded)
    {
        validMessage = true;
        MediaObjectsLoadedMessenger *msg = [MediaObjectsLoadedMessenger new];
        msg.Message = RootMediaGroupLoaded;
        CFBridgingRetain(msg);
        [mediaSource addObserver:self
                      forKeyPath:@"rootMediaGroup"
                         options:0
                         context:(__bridge void *)msg];
        KVO_Observer *observer = [[KVO_Observer alloc] initWithObservee:mediaSource andKeyPath:@"rootMediaGroup" andObserver:self];
        [KVO_Observers addObject:observer];
        [self reportStatus:@"Attempting to load system root media group..."];
        [mediaSource rootMediaGroup];
    }
    else if (message == RootMediaGroupLoaded)
    {
        validMessage = true;
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
        
        if (useAllPhotosAlbum) {
            useAllPhotosAlbum = false;
            for (MLMediaGroup *album in albums.childGroups) {
                NSString *albumIdentifier = [album.attributes objectForKey:@"identifier"];
                if ([albumIdentifier isEqualToString:@"allPhotosAlbum"]) {
                    useAllPhotosAlbum = true;
                }
            }
        }
        
        for (MLMediaGroup *album in albums.childGroups)
        {
            NSString *albumIdentifier = [album.attributes objectForKey:@"identifier"];
            
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
                AlbumsToLoad++;
                KVO_Observer *observer = [[KVO_Observer alloc] initWithObservee:album andKeyPath:@"mediaObjects" andObserver:self];
                [KVO_Observers addObject:observer];
                [self reportStatus:[NSString stringWithFormat:@"Loading photo album called %@...", albumIdentifier]];
                [album mediaObjects];
                
                if (useAllPhotosAlbum) {
                    break;
                }
            }
        }
        
        if (AlbumsToLoad == 0) {
            [self reportErrorFindingMedia];
        }
    }
    else if (message == SubMediaGroupLoaded)
    {
        NSLog(@"Sub-Media Group Loaded");
    }
    else if (message == MediaObjectsLoaded)
    {
        validMessage = true;
        NSArray * mediaObjects = messageContainer.MediaGroup.mediaObjects;
        
        for (MLMediaObject * mediaObject in mediaObjects)
        {
            [MediaObjects addObject:mediaObject];
            NSString *reportString = [MediaLibraryAccessor getFileNameFromMediaObject:mediaObject];
            [self reportStatus:reportString];
        }
        
        AlbumsLoaded++;
        if (AlbumsLoaded >= AlbumsToLoad) {
            
            Finished = TRUE;
            [self callDelegateAndExit];
        }
    }
    
    CFBridgingRelease(context);
    if (!validMessage) {
        [self reportErrorFindingMedia];
    }
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
    ErrorMessage = [self getErrorLoadingPhotosMessage];
    [self callDelegateAndExit];
}

- (NSString *)getErrorLoadingPhotosMessage {
    
    return @"Unable to load the system photo library. Please ensure the library exists with GPS-tagged photos. Also please ensure the photo library is set to 'Use as System Photo Library' in the Photos app Preferences. You can also use a folder or file.";
}

- (void)reportStatus:(NSString *)status {
    
    StatusMessage = status;
    if (!Delegate) { return; }
    SEL selector = NSSelectorFromString(StatusReportSelector);
    IMP imp = [Delegate methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(Delegate, selector);
}

- (void)setDelegate:(id)del withSelector:(NSString *)sel {
    
    Delegate = del;
    Selector = sel;
}

- (void)setStatusReportSelector:(NSString *)sel {
    
    StatusReportSelector = sel;
}

- (NSMutableArray *)getMediaObjects {
    
    return MediaObjects;
}

+ (NSString *)getFileNameFromMediaObject:(MLMediaObject *)mediaObject {
    
    return mediaObject.URL.absoluteString;
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
