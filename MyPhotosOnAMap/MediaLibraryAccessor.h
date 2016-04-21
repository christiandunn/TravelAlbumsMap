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
    NSMutableArray *MediaObjects;
    bool Finished;
    
    id Delegate;
    NSString *Selector;
}

@property MLMediaLibrary *mediaLibrary;
@property MLMediaGroup *allPhotosAlbum;

- (void)initialize;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context;

- (void)setDelegate:(id)del withSelector:(NSString *)sel;

- (NSMutableArray *)getMediaObjects;

@end