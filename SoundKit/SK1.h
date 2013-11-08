//
//  SK1.h
//  SoundKit
//
//  Created by david karam on 11/7/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SK1 : SKShapeNode
@property float alpha;
@property int pitch;
- (id) initWithAlpha:(float)alpha AndPitch:(int)pitch;
@end
