//
//  SKBus.h
//  SoundKit
//
//  Created by david karam on 11/13/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SKNU.h"

@interface SKBus : NSObject

@property (readonly) AUNode node;
@property (readonly) AudioUnit unit;

@property (readonly) SKNU * sampler;
@property (readonly) SKNU * effect;
@property (readonly) NSURL * bankURL;

- (id) init:(NSURL*)bankURL;
- (id) init:(NSString*)bankURL :(NSString*)type;
- (void) wire:(AUGraph)processingGraph :(AUNode)mixer :(int)mixerInputElement;
- (void)noteOn:(UInt32)noteNum;
- (void)noteOn:(UInt32)noteNum :(UInt32)velocity;
- (void)noteOff:(UInt32)noteNum;


@end
