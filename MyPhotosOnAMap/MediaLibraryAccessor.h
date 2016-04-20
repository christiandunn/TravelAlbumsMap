//
//  MediaLibraryAccessor.h
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 4/19/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaLibrary/MediaLibrary.h>

@interface MediaLibraryAccessor : NSObject {
    ;
}

@property MLMediaLibrary *mediaLibrary;
@property MLMediaGroup *allPhotosAlbum;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context;

@end
