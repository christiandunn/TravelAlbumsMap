//
//  MediaLibraryAccessor.h
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 4/19/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaLibrary/MediaLibrary.h>
#import <MapKit/MapKit.h>

typedef enum    {
                    MediaLibraryLoaded,
                    RootMediaGroupLoaded,
                    SubMediaGroupLoaded,
                    MediaObjectsLoaded
    
                } MediaLoadingMessage;

@interface MediaLibraryAccessor : NSObject {
    NSMutableArray *MediaObjects;
    MLMediaGroup *albums;
    bool Finished;
    bool ErrorState;
    
    NSInteger AlbumsToLoad;
    NSInteger AlbumsLoaded;
    
    NSString *ErrorMessage;
    id Delegate;
    NSString *Selector;
    NSMutableArray *KVO_Observers;
}

@property MLMediaLibrary *mediaLibrary;
@property MLMediaGroup *allPhotosAlbum;
@property bool ErrorState;
@property NSString *ErrorMessage;

- (void)initialize;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context;

- (void)setDelegate:(id)del withSelector:(NSString *)sel;

- (NSMutableArray *)getMediaObjects;
- (void)callDelegateAndExit;
- (void)removeObserverFromMediaLibrary;
- (void)reportErrorFindingMedia;

+ (NSDictionary *)getImagePropertiesDictionary:(NSURL *)path;
+ (NSString *)getExifDateTimeOriginal:(NSURL *)path;
+ (NSNumber *)getGpsAltitude:(NSURL *)path;
+ (NSNumber *)getGpsSpeed:(NSURL *)path;
+ (CLLocationCoordinate2D)getLocation:(NSURL *)path;

@end

@interface MediaObjectsLoadedMessenger : NSObject {
    
    MLMediaGroup *MediaGroup;
    MediaLoadingMessage Message;
}

@property MLMediaGroup *MediaGroup;
@property MediaLoadingMessage Message;

@end

@interface KVO_Observer : NSObject {
    
    id Observee;
    id Observer;
    NSString *KeyPath;
}

@property id Observee;
@property id Observer;
@property NSString *KeyPath;

- (id)initWithObservee:(id)observee andKeyPath:(NSString *)keyPath andObserver:(id)observer;

@end