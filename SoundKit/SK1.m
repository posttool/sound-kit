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
@synthesize size     = _size;
@synthesize playing     = _playing;
@synthesize bus     = _bus;
- (id) initWithAlpha:(float)alpha AndPitch:(int)pitch AndSize:(int)size AndStroke:(int)stroke AndBus:(SKBus*)bus
{
    self = [super init];
    
    if (self != nil)
    {
        self.pitch = pitch;
        self.alpha = alpha;
        self.size = size;
        self.playing = false;
        self.bus = bus;
        NSLog(@"bus=%@", self.bus);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddArc(path, NULL, 0,0, self.size, 0, M_PI*2, YES);
        self.path = path;
        [self color1];
        self.lineWidth = stroke;
        self.strokeColor = [SKColor whiteColor];
        self.glowWidth = 1;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size];
        self.physicsBody.dynamic = YES;
        self.physicsBody.categoryBitMask = 1;
        self.physicsBody.collisionBitMask = 1;
        self.physicsBody.contactTestBitMask = 1;
        self.physicsBody.friction = 0;
        self.physicsBody.restitution = 1;
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
-(void)contact
{
    if (self.playing)
        return;
//    if (arc4random()%10==1)
//        self.pitch += (arc4random()%10)-5;
    self.playing = YES;
    self.glowWidth = 13;
    [_bus noteOn:self.pitch :64];//contact.collisionImpulse*100];
    double delayInSeconds = self.size/40.0;//MAX(.3, contact.collisionImpulse);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_bus noteOff:self.pitch];
        self.glowWidth = 1;
        self.playing = NO;
    });

}


@end
