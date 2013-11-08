//
//  GDSoundEngine.h
//  SoundKit
//
//  Created by david karam on 11/6/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface SKEngine : NSObject

@property (getter = isPlaying) BOOL playing;

- (void)playNoteOn:(UInt32)noteNum :(UInt32)velocity;
- (void)playNoteOff:(UInt32)noteNum;

@end