//
//  SK1.h
//  SoundKit
//
//  Created by david karam on 11/7/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SKBus.h"
#import "SKField.h"

@interface SKThing : SKShapeNode
@property (readonly) SKColor * color;
@property (readonly) int pitch;
@property (readonly) int size;
@property (readonly) bool playing;
@property (readonly) SKBus * bus;

- (id) initWithPitch:(int)pitch andSize:(int)size andColor:(SKColor*)color andBus:(SKBus*)bus;
- (void) contact;
- (void) destroy;

@end
