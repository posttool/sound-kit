//
//  SKScale.h
//  SoundKit
//
//  Created by david karam on 11/15/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKThingProp.h"

@interface SKScale : NSObject

@property (readonly) NSMutableArray * scale;
@property (readonly) NSMutableArray * allPitches;

- (id) initWithJSONFile:(NSString*)filename;
- (id) initWithArray:(NSArray*)array;
- (int) pitchAt:(int)index;
- (SKThingProp *) propAt:(int)index;

@end
