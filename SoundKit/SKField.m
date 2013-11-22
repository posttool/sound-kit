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
#import "SKThat.h"

@implementation SKField

SKNode *world;
SKAudio *sound;
NSMutableArray *joints;
SKScale *scale;
SKNode *grid;
SKNode *thats;
SKNode *things;
SKShapeNode *touch;

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        CGRect f = self.frame;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:f];
        
        self.physicsWorld.speed = 1.1;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        CMMotionManager * motionManager = [[CMMotionManager alloc] init];
        motionManager.accelerometerUpdateInterval = .1;
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMAccelerometerData  *data, NSError *error) {
                                                self.physicsWorld.gravity = CGVectorMake(data.acceleration.x, data.acceleration.y);
                                                if(error)
                                                {
                                                    NSLog(@"%@", error);
                                                }
                                            }];
        
        scale = [[SKScale alloc] initWithJSONFile:@"major"];

        sound = [[SKAudio alloc] init];
        
        joints = [[NSMutableArray alloc] init];
        
        
        
        
        //
        world = [SKNode node];
        [self addChild:world];
        
        grid = [[SKNode alloc] init];
        float a = self.frame.size.height/pathsteps;
        for (int i=0; i<pathsteps; i++)
        {
            SKShapeNode *l = [[SKShapeNode alloc]init];
            l.path = [self line:0 :i*a :self.frame.size.width :i*a];
            l.strokeColor = [SKColor colorWithRed:0 green:.8 blue:1 alpha:.03];
            [grid addChild:l];
        }
        [world addChild:grid];
        
        thats = [[SKNode alloc] init];
        [world addChild:thats];
        
        things = [[SKNode alloc] init];
        [world addChild:things];
        
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
    float ip = 1 - p;
    int pitch = [scale pitchAt:p * 22 + 22];
    SKColor *c= [SKColor colorWithRed:1 green:1 blue:1 alpha:p+.1];
    SKThing *sk = [[SKThing alloc] initWithPitch:pitch
                                         andSize:CGSizeMake(ip*64+16, ip*64+16)
                                        andColor:c
                                          andBus:[sound busAt:p*3]];
    sk.position = location;
    [things addChild:sk];
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
        else
        {
            [touchLocations addObject:[[NSMutableArray alloc]initWithObjects:[NSValue valueWithCGPoint:location], nil]];
        }
    }
}

float pathsteps = 24;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (int i=0; i < touchLocations.count; i++)
    {
        UITouch * uitouch = [[touches objectEnumerator] nextObject];
        CGPoint location = [uitouch locationInNode:self];
        NSMutableArray * locs = [touchLocations objectAtIndex:i];
        [locs addObject:[NSValue valueWithCGPoint:location]];
        if (touchedNodes.count>i)
        {
            SKThing * thing = [touchedNodes objectAtIndex:i];
            thing.position = location;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (int i=0; i < touchLocations.count; i++)
    {
        NSArray *p = [touchLocations objectAtIndex:i];
        CGPoint ps0 = [self posAt:i :0];
        CGPoint ps1 = [self posAt:i :-1];
        if (touchedNodes.count > i)
        {
            SKThing * thing = [touchedNodes objectAtIndex:i];
            if (p.count > pathsteps)
            {
                [thing destroy];
                continue;
            }
            CGVector vec = CGVectorMake((ps1.x - ps0.x) * 17, (ps1.y - ps0.y) * 17);
            [thing.physicsBody applyForce:vec];
            thing.alpha = 1;
        }
        else
        {
//            CGRectStandardize(<#CGRect rect#>)
            CGSize size = CGSizeMake(ps0.x - ps1.x, ps0.y - ps1.y);
            if (size.width + size.height != 0)
            {
                SKThat *sk = [[SKThat alloc] initWithSize:size];
                sk.position = ps1;
                [thats addChild:sk];
            }
        }
    }

    [touchedNodes removeAllObjects];
    [touchLocations removeAllObjects];
    touch.path = nil;
    [self setTimeScale:1];
}

// the update callback!
-(void)update:(CFTimeInterval)currentTime
{
    if (touchLocations.count != 0)
    {
        //NSLog(@"touches=%@",touchLocations);
        NSMutableArray * locs = [touchLocations objectAtIndex:0];
        float a = MAX(0, 1-locs.count/pathsteps);
        touch.strokeColor = [[SKColor alloc] initWithRed:1 green:1 blue:1 alpha:a];
        if (touchedNodes.count != 0)
        {
            touch.path = [self line:[self posAt:0 :0] :[self posAt:0 :-1]];
            SKThing *thing = [touchedNodes objectAtIndex:0];
            thing.alpha = a;
        }
        else
        {
            CGPoint a = [self posAt:0 :0];
            CGPoint b = [self posAt:0 :-1];
            
            CGMutablePathRef path = [self line:a :b];
            CGPathAddLineToPoint(path, NULL, b.x, a.y);
            CGPathAddLineToPoint(path, NULL, a.x, a.y);
            CGPathAddLineToPoint(path, NULL, a.x, b.y);
            CGPathAddLineToPoint(path, NULL, b.x, b.y);
            
            touch.path = path;
            
        }
        
    }
}

-(CGPoint)posAt:(int)tidx :(int)hidx
{
    NSArray *p = [touchLocations objectAtIndex:tidx];
    if (hidx < 0) hidx = p.count + hidx;
    NSValue * v = [p objectAtIndex:hidx];
    return [v CGPointValue];
}



-(CGMutablePathRef)line:(float)x0 :(float)y0 :(float)x1 :(float)y1
{
    return [self line:CGPointMake(x0,y0) :CGPointMake(x1,y1)];
}

-(CGMutablePathRef)line:(CGPoint)a :(CGPoint)b
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, a.x, a.y);
    CGPathAddLineToPoint(path, NULL, b.x, b.y);
    return path;
}

@end
