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
@synthesize size = _size;
@synthesize playing = _playing;
@synthesize bus = _bus;

- (id) initWithPitch:(int)pitch andSize:(int)size andColor:(SKColor*)color andBus:(SKBus*)bus
{
    self = [super init];
    
    if (self != nil)
    {
        _color = color;
        _pitch = pitch;
        _size = size;
        _playing = false;
        _bus = bus;
        
        CGSize size = CGSizeMake(self.size*.5, self.size);
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        CGMutablePathRef path = CGPathCreateMutable();
//        CGPathAddArc(path, NULL, 0,0, self.size, 0, M_PI*2, YES);
        CGAffineTransform t = CGAffineTransformMakeTranslation(-size.width/2, -size.height/2);
        CGPathAddRect(path, &t, rect);
        self.path = path;
        [self color1];
        self.lineWidth = .1;
        self.strokeColor = _color;
        self.glowWidth = 0;
        
//        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size];
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.dynamic = YES;
        self.physicsBody.categoryBitMask = 1;
        self.physicsBody.collisionBitMask = 1;
        self.physicsBody.contactTestBitMask = 1;
        self.physicsBody.friction = 0;
        self.physicsBody.restitution = .96;
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
-(void)contact//:(NSArray*)pattern
{
//    if (self.playing)
//        return;
//    if (arc4random()%10==1)
//        self.pitch += (arc4random()%10)-5;
//    NSLog(@"pitch=%d", self.pitch);

    NSMutableArray * sa = [[NSMutableArray alloc] init];
    int s = arc4random() % 3 + 3;
    for (int i=0; i<s; i++)
    {
        //float p = 3 *i/(float)s+1;//arc4random() % 3 ;
        float d = arc4random()%2 == 0 ? 0.5 : 1.0; //pattern[i].duration
        [sa addObject:[SKAction runBlock:^(void){ [_bus noteOn:self.pitch :(i == 0) ? 127: 66]; }]];
        [sa addObject:[self one:.1 :(i == 0) ? 20: 6]];
        [sa addObject:[self two:d-.1 :(i == 0) ? 20: 6]];
    }
    [sa addObject:[SKAction waitForDuration:1.0]];
    [sa addObject:[SKAction runBlock:^(void){ [_bus noteOff:self.pitch ]; _playing = NO; }]];

//    if (_playing)
//        [_bus noteOff:self.pitch ];
    _playing = YES;
    [self removeAllActions];
    [self runAction:[SKAction sequence:sa]];
}

-(SKAction*) one:(float)time :(float)gscale
{
    return [SKAction customActionWithDuration:time actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        float r = elapsedTime/time;
        self.yScale = self.xScale = r*(gscale/4.0)+1;
        self.glowWidth = r*gscale;
    }];
}

-(SKAction*) two:(float)time :(float)gscale
{
    return [SKAction customActionWithDuration:time actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        float r = elapsedTime/time;
        self.yScale = self.xScale = 2-r;
        self.glowWidth = (1-r)*gscale;
    }];
}

-(void)destroy
{
    [self removeAllActions];
    [_bus noteOff:self.pitch];
    [self removeFromParent];
}
@end
