//
//  SK1.h
//  SoundKit
//
//  Created by david karam on 11/7/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SKEngine.h"

@interface SK1 : SKShapeNode
@property float alpha;
@property int pitch;
@property int size;
@property bool playing;
- (id) initWithAlpha:(float)alpha AndPitch:(int)pitch AndSize:(int)size AndStroke:(int)stroke;
-(void) contact:(SKEngine*)sound;
@end
