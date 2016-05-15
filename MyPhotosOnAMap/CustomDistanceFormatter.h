//
//  CustomDistanceFormatter.h
//  The Photo Map
//
//  Created by Christian Dunn on 5/15/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

#define METERS_TO_FEET  3.2808399
#define METERS_TO_MILES 0.000621371192
#define METERS_CUTOFF   1000
#define FEET_CUTOFF     3281
#define FEET_IN_MILES   5280

@interface CustomDistanceFormatter : NSObject {
    
    
}

- (NSString *)stringWithDistance:(double)distance;
- (NSString *)stringWithDouble:(double)value;

@end
