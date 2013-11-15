//
//  SKThingProp.h
//  SoundKit
//
//  Created by david karam on 11/15/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface SKThingProp : NSObject

@property (readonly) int pitch;
@property (readonly) SKColor * color;
@property (readonly) float size;
@property (readonly) NSString * name;

- (id) initWithDict:(NSDictionary *) dict;

@end
