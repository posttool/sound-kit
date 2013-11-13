//
//  SKNu.h
//  SoundKit
//
//  Created by david karam on 11/13/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <Foundation/Foundation.h>

@interface SKBus : NSObject
@property (readonly) AUNode samplerNode;
@property (readonly) AudioUnit samplerUnit;
@property (readonly) NSURL * bankURL;
- (id) init:(NSURL*)bankURL;
- (void) wire:(AUGraph)processingGraph :(AUNode)mixer :(int)samplerOutputElement :(int)mixerInputElement;
- (void)noteOn:(UInt32)noteNum :(UInt32)velocity;
- (void)noteOff:(UInt32)noteNum;


@end
