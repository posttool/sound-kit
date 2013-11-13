//
//  SK1.h
//  SoundKit
//
//  Created by david karam on 11/7/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SKBus.h"

@interface SK1 : SKShapeNode
@property float alpha;
@property int pitch;
@property int size;
@property bool playing;
@property (strong, atomic) SKBus * bus;
- (id) initWithAlpha:(float)alpha AndPitch:(int)pitch AndSize:(int)size AndStroke:(int)stroke AndBus:(SKBus*)bus;
-(void) contact;
@end
