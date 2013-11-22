//
//  SK1.m
//  SoundKit
//
//  Created by david karam on 11/7/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SKThat.h"

@implementation SKThat

@synthesize size = _size;

- (id) initWithSize:(CGSize)size
{
    self = [super init];
    
    if (self != nil)
    {
        _size = size;
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGPathMoveToPoint(path, NULL, 0, 0);
//        CGPathAddLineToPoint(path, NULL, 0, size.height);
//        CGPathAddLineToPoint(path, NULL, size.width, size.height);
//        CGPathAddLineToPoint(path, NULL, size.width, 0);
//        CGPathAddLineToPoint(path, NULL, size.width * .2, 0);
//        self.path = path;
//        
//        self.lineWidth = 2;
//        self.strokeColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:.8];
//        
//        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:path];
        
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGPathAddRect(path, NULL, rect);
        
        CGPathRef path = CGPathCreateWithRoundedRect(rect, 7, 7, NULL);
        
        self.path = path;
        
        self.lineWidth = 5;
        self.strokeColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:.8];
        self.glowWidth = 0;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:rect];

        
        
        
        self.physicsBody.dynamic = YES;
        self.physicsBody.categoryBitMask = 1;
        self.physicsBody.collisionBitMask = 1;
        self.physicsBody.contactTestBitMask = 1;
    }
    
    return self;
}



-(void)contact//:(NSArray*)pattern
{
}

-(void)destroy
{
    [self removeAllActions];
    [self removeFromParent];
    [self release];
}
@end
