//
//  SK1.m
//  SoundKit
//
//  Created by david karam on 11/7/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SKThing.h"

@implementation SKThing

@synthesize color = _color;
@synthesize pitch = _pitch;
@synthesize alpha = _alpha;
@synthesize size = _size;
@synthesize playing = _playing;
@synthesize bus = _bus;

- (id) initWithAlpha:(float)alpha andPitch:(int)pitch andSize:(int)size andColor:(SKColor*)color andBus:(SKBus*)bus
{
    self = [super init];
    
    if (self != nil)
    {
        _color = color;
        _pitch = pitch;
        _alpha = alpha;
        _size = size;
        _playing = false;
        _bus = bus;
        
        CGMutablePathRef path = CGPathCreateMutable();
//        CGPathAddArc(path, NULL, 0,0, self.size, 0, M_PI*2, YES);
        CGAffineTransform t = CGAffineTransformMakeTranslation(-self.size/2, -self.size/2);
        CGPathAddRect(path, &t, CGRectMake(0,0,self.size, self.size));
        self.path = path;
        [self color1];
        self.lineWidth = .1;
        self.strokeColor = _color;
        self.glowWidth = 0;
        
//        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size];
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size, self.size)];
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
    self.fillColor = _color;//[SKColor colorWithRed:.1 green:.6 blue:1 alpha:self.alpha];
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
    NSLog(@"pitch=%d", self.pitch);
    double s = 4;
    _playing = YES;
    SKAction *a = [SKAction sequence:@[
      [SKAction runBlock:^(void){ [_bus noteOn:self.pitch :127]; }],
      [self one:.1], [self two:1.5],
      [SKAction runBlock:^(void){ [_bus noteOn:self.pitch :48]; }],
      [self one:.3], [self two:.3],
      [SKAction runBlock:^(void){ [_bus noteOn:self.pitch :48]; }],
      [self one:.4], [self two:.4],
      [SKAction runBlock:^(void){ [_bus noteOff:self.pitch ]; _playing = NO; }],
    ]];

    
    [self runAction:a];

}

-(SKAction*) one:(float)time
{
    return [SKAction customActionWithDuration:time actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        float r = elapsedTime/time;
        self.yScale = self.xScale = r*5+1;
        self.glowWidth = r*20;
    }];
}

-(SKAction*) two:(float)time
{
    return [SKAction customActionWithDuration:time actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        float r = elapsedTime/time;
        self.yScale = self.xScale = 2-r;
        self.glowWidth = (1-r)*20;
    }];
}

@end
