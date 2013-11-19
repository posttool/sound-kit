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
NSMutableArray *scale;

SKShapeNode *touch;

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        sound = [[SKAudio alloc] init];
        
        joints = [[NSMutableArray alloc] init];
        
        SKScale * scale = [[SKScale alloc] initWithJSONFile:@"major"];
        
        for (NSUInteger i = 0; i < 21; ++i)
        {
            
            int pitch = [scale pitchAt:i + 22];
            SKThingProp * prop = [scale propAt:i];
            SKThing *sk = [[SKThing alloc] initWithAlpha:1
                                                andPitch:pitch
                                                 andSize:prop.size
                                                andColor:prop.color
                                                  andBus:[sound busAt:i%3]];
            
            sk.position = CGPointMake(arc4random() % (int)size.width, arc4random() % (int)size.height);
            [self addChild:sk];

}
        
        
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
        
        
//        self.motionManager = [[CMMotionManager alloc] init];
//        self.motionManager.accelerometerUpdateInterval = .2;
//        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
//                                                 withHandler:^(CMAccelerometerData  *data, NSError *error) {
//                                                     self.physicsWorld.gravity = CGVectorMake(data.acceleration.x, data.acceleration.y);
//                                                     if(error)
//                                                     {
//                                                         NSLog(@"%@", error);
//                                                     }
//                                                 }];
        
        touch = [SKShapeNode node];
        touch.lineWidth = .1;
        touch.strokeColor = [[SKColor alloc] initWithRed:1 green:1 blue:1 alpha:1];

        [self addChild:touch];
        
        
    }
    return self;
}

-(void)setTimeScale:(float)scale
{
    NSLog(@"%f",scale);
    self.physicsWorld.speed = scale - .5;
}




- (void)didSimulatePhysics
{
    [self centerOnNode: [self childNodeWithName: @"//camera"]];
   // NSLog(@"HERE");
}

- (void) centerOnNode: (SKNode *) node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x, node.parent.position.y - cameraPositionInScene.y);
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

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (int i=0; i < touchedNodes.count; i++)
    {
        SKThing * thing = [touchedNodes objectAtIndex:i];
        UITouch * touch = [[touches objectEnumerator] nextObject];
        CGPoint location = [touch locationInNode:self];
        thing.position = location;
        NSMutableArray * locs = [touchLocations objectAtIndex:i];
        [locs addObject:[NSValue valueWithCGPoint:location]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (int i=0; i < touchedNodes.count; i++)
    {
        SKThing * thing = [touchedNodes objectAtIndex:i];
        UITouch * touch = [[touches objectEnumerator] nextObject];
        CGPoint location = [touch locationInNode:self];
        thing.position = location;
        NSMutableArray * locs = [touchLocations objectAtIndex:i];
        CGPoint lastLoc = [[locs lastObject] CGPointValue];
        CGVector vec = CGVectorMake((location.x - lastLoc.x) * 17, (location.y - lastLoc.y) * 17);
        [thing.physicsBody applyForce:vec];
    }
    [touchedNodes removeAllObjects];
    [touchLocations removeAllObjects];
    touch.path = nil;
    [self setTimeScale:1];
}




-(void)update:(CFTimeInterval)currentTime
{
    if (touchLocations.count != 0)
    {
        NSLog(@"touches=%@",touchLocations);
        CGMutablePathRef path = CGPathCreateMutable();
        CGAffineTransform t = CGAffineTransformMakeTranslation(0,0);//-self.size.width/2, -self.size.height/2
        NSArray *p = [touchLocations objectAtIndex:0];
        CGPoint ps[p.count];
        for (int i=0; i < p.count; i++)
        {
            NSValue * v = [p objectAtIndex:i];
            ps[i] = [v CGPointValue];
        }
        NSLog(@"PATH=%@",p);
        CGPathAddLines(path, &t, ps, p.count);
        touch.path = path;
    }
}

@end
