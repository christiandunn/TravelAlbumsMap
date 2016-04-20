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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSDictionary *options = @{
                              MLMediaLoadSourceTypesKey: @(MLMediaSourceTypeImage),
                              MLMediaLoadIncludeSourcesKey: @[MLMediaSourcePhotosIdentifier]
                              };
    
    self.mediaLibrary = [[MLMediaLibrary alloc] initWithOptions:options];
    
    [self.mediaLibrary addObserver:self
                        forKeyPath:@"mediaSources"
                           options:0
                           context:(__bridge void *)@"mediaLibraryLoaded"];
    
    [self.mediaLibrary.mediaSources objectForKey:MLMediaSourcePhotosIdentifier];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    MLMediaSource *mediaSource = [self.mediaLibrary.mediaSources objectForKey:MLMediaSourcePhotosIdentifier];
    
    if (context == (__bridge void *)@"mediaLibraryLoaded")
    {
        [mediaSource addObserver:self
                      forKeyPath:@"rootMediaGroup"
                         options:0
                         context:(__bridge void *)@"rootMediaGroupLoaded"];
        
        [mediaSource rootMediaGroup];
    }
    else if (context == (__bridge void *)@"rootMediaGroupLoaded")
    {
        MLMediaGroup *albums = [mediaSource mediaGroupForIdentifier:@"TopLevelAlbums"];
        
        for (MLMediaGroup *album in albums.childGroups)
        {
            NSString *albumIdentifier = [album.attributes objectForKey:@"identifier"];
            
            if ([albumIdentifier isEqualTo:@"allPhotosAlbum"])
            {
                self.allPhotosAlbum = album;
                
                [album addObserver:self
                        forKeyPath:@"mediaObjects"
                           options:0
                           context:@"mediaObjects"];
                
                [album mediaObjects];
                
                break;
            }
        }
    }
    else if (context == (__bridge void *)@"mediaObjects")
    {
        NSArray * mediaObjects = self.allPhotosAlbum.mediaObjects;
        
        for(MLMediaObject * mediaObject in mediaObjects)
        {
            //NSURL * url  = mediaObject.URL;
            ;
        }
    }
}

@end
