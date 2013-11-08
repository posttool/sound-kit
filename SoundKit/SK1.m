//
//  SK1.m
//  SoundKit
//
//  Created by david karam on 11/7/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SK1.h"

@implementation SK1
@synthesize pitch     = _pitch;
@synthesize alpha     = _alpha;
- (id) initWithAlpha:(float)alpha AndPitch:(int)pitch
{
    self = [super init];
    
    if (self != nil)
    {
        self.pitch = pitch;
        self.alpha = alpha;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddArc(path, NULL, 0,0, 40, 0, M_PI*2, YES);
        self.path = path;
        [self color1];
        self.lineWidth = 4.0;
        self.strokeColor = [SKColor whiteColor];
        self.glowWidth = 1;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:36];
        self.physicsBody.dynamic = YES;
        self.physicsBody.categoryBitMask = 1;
        self.physicsBody.collisionBitMask = 1;
        self.physicsBody.contactTestBitMask = 1;
        self.physicsBody.friction = 0;
        self.physicsBody.restitution = .8;
        self.physicsBody.linearDamping = 0;

    }
    
    return self;
}

-(void)color1
{
    self.fillColor = [SKColor colorWithRed:.1 green:.6 blue:1 alpha:self.alpha];
}

-(void)color2
{
    self.fillColor = [SKColor colorWithRed:.93 green:.96 blue:.90 alpha:.9];
}


@end
