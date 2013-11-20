//
//  SKMyScene.m
//  SoundKit
//
//  Created by david karam on 11/4/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SKField.h"
#import "SKAudio.h"
#import "SKScale.h"
#import "SKThing.h"
#import "SKThingProp.h"

@implementation SKField

CGPoint anchorPoint;
SKNode *world;
SKNode *camera;
NSMutableArray *colors;
SKAudio *sound;
NSMutableArray *joints;
SKScale *scale;

SKShapeNode *touch;

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        sound = [[SKAudio alloc] init];
        
        joints = [[NSMutableArray alloc] init];
        
        scale = [[SKScale alloc] initWithJSONFile:@"major"];
        
        
        self.physicsWorld.speed = 1.1;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        
        //
        anchorPoint = CGPointMake (0.5,0.5);
        world = [SKNode node];
        [self addChild:world];
        camera = [SKNode node];
        camera.name = @"camera";
        [world addChild:camera];
        
        
        CMMotionManager * motionManager = [[CMMotionManager alloc] init];
        motionManager.accelerometerUpdateInterval = .2;
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData  *data, NSError *error) {
                                                     self.physicsWorld.gravity = CGVectorMake(data.acceleration.x, data.acceleration.y);
                                                     if(error)
                                                     {
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
        
        touch = [SKShapeNode node];
        touch.lineWidth = .1;
        touch.strokeColor = [[SKColor alloc] initWithRed:1 green:1 blue:1 alpha:.3];
        [world addChild:touch];
        
        
        
    }
    return self;
}

-(void)setTimeScale:(float)scale
{
    NSLog(@"%f",scale);
    self.physicsWorld.speed = scale - .5;
}

-(void)addThing:(CGPoint)location
{
    location.y = self.size.height - location.y;
    float p = location.y / self.size.height;
    int pitch = [scale pitchAt:p * 22 + 22];
    SKColor *c= [SKColor colorWithRed:1 green:1 blue:1 alpha:p+.1];
    SKThing *sk = [[SKThing alloc] initWithPitch:pitch
                                         andSize:(1-p)*64+16
                                        andColor:c
                                          andBus:[sound busAt:p*3]];
    sk.position = location;
    [world addChild:sk];
}

-(void)reset
{
    for (SKNode * child in [self children])
    {
        SKThing *a = (SKThing*) child;
        BOOL anode = [a isKindOfClass:[SKThing class]];
        if (anode)
        {
            [a destroy];
        }
    }
}



// stufu
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKThing *a = (SKThing*) contact.bodyA.node;
    BOOL anode = [a isKindOfClass:[SKThing class]];

    SKThing *b = (SKThing*) contact.bodyB.node;
    BOOL bnode = [b isKindOfClass:[SKThing class]];
    
    if (anode && bnode)
    {
        [a contact];
        [b contact];
    }
    //do they love each other

    //    if (anode && bnode && ![joints containsObject:a] && ![joints containsObject:b])
    //    {
    //        SKPhysicsJointSpring* spring = [SKPhysicsJointSpring jointWithBodyA:a.physicsBody bodyB:b.physicsBody anchorA:b.position anchorB:a.position];
    //        [self.physicsWorld addJoint:spring];
    //        [joints addObject:a];
    //        [joints addObject:b];
    //    }

}

- (void)didEndContact:(SKPhysicsContact *)contact
{
}

//


// touching
//speed
//size
//scale

NSMutableArray *touchLocations;
NSMutableArray *touchedNodes;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchedNodes = [[NSMutableArray alloc] init];
    touchLocations = [[NSMutableArray alloc] init];
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        SKSpriteNode * touchedNode = (SKSpriteNode *)[self nodeAtPoint:location];
        BOOL isThing = [touchedNode isKindOfClass:[SKThing class]];
        if (isThing)
        {
            [touchedNodes addObject:touchedNode];
            [touchLocations addObject:[[NSMutableArray alloc]initWithObjects:[NSValue valueWithCGPoint:location], nil]];
            touchedNode.physicsBody.velocity = CGVectorMake(0,0);
        }
    }
}

float pathsteps = 50.0;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (int i=0; i < touchedNodes.count; i++)
    {
        SKThing * thing = [touchedNodes objectAtIndex:i];
        UITouch * uitouch = [[touches objectEnumerator] nextObject];
        CGPoint location = [uitouch locationInNode:self];
        thing.position = location;
        NSMutableArray * locs = [touchLocations objectAtIndex:i];
        [locs addObject:[NSValue valueWithCGPoint:location]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    for (int i=0; i < touchedNodes.count; i++)
//    {
//        SKThing * thing = [touchedNodes objectAtIndex:i];
//        UITouch * touch = [[touches objectEnumerator] nextObject];
//        CGPoint location = [touch locationInNode:self];
//        thing.position = location;
//        NSMutableArray * locs = [touchLocations objectAtIndex:i];
//        CGPoint lastLoc = [[locs lastObject] CGPointValue];
//        CGVector vec = CGVectorMake((location.x - lastLoc.x) * 17, (location.y - lastLoc.y) * 17);
//        [thing.physicsBody applyForce:vec];
//    }
    for (int i=0; i < touchedNodes.count; i++)
    {
        NSArray *p = [touchLocations objectAtIndex:i];
        SKThing * thing = [touchedNodes objectAtIndex:i];
        if (p.count > pathsteps)
        {
            [thing destroy];
            continue;
        }
        CGPoint ps0 = [self posAt:i :0];
        CGPoint ps1 = [self posAt:i :-1];
        CGVector vec = CGVectorMake((ps1.x - ps0.x) * 17, (ps1.y - ps0.y) * 17);
        [thing.physicsBody applyForce:vec];
    }

    [touchedNodes removeAllObjects];
    [touchLocations removeAllObjects];
    touch.path = nil;
    [self setTimeScale:1];
}

-(CGPoint)posAt:(int)tidx :(int)hidx
{
    NSArray *p = [touchLocations objectAtIndex:tidx];
    if (hidx < 0) hidx = p.count + hidx;
    NSValue * v = [p objectAtIndex:hidx];
    return [v CGPointValue];
}


-(void)update:(CFTimeInterval)currentTime
{
    if (touchLocations.count != 0)
    {
        NSLog(@"touches=%@",touchLocations);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint ps = [self posAt:0 :0];
        CGPathMoveToPoint(path, NULL, ps.x, ps.y);
        ps = [self posAt:0 :-1];
        CGPathAddLineToPoint(path, NULL, ps.x, ps.y);
        touch.path = path;
        NSMutableArray * locs = [touchLocations objectAtIndex:0];
        float a = MAX(0, 1-locs.count/pathsteps);
        touch.strokeColor = [[SKColor alloc] initWithRed:1 green:1 blue:1 alpha:a];
    }
}

@end
