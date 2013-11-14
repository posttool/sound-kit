//
//  SKMyScene.m
//  SoundKit
//
//  Created by david karam on 11/4/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SKMyScene.h"
#import "SKAudio.h"
#import "SK1.h"

@implementation SKMyScene

CGPoint anchorPoint;
SKNode *world;
SKNode *camera;

SKAudio *sound;
NSMutableArray *joints;
NSMutableArray *scale;


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        
        sound = [[SKAudio alloc] init];
        
        joints = [[NSMutableArray alloc] init];

        
        scale = [NSMutableArray arrayWithObjects:
                 [NSNumber numberWithInt:2],
                 [NSNumber numberWithInt:2],
                 [NSNumber numberWithInt:3],
                 [NSNumber numberWithInt:2],
                 [NSNumber numberWithInt:3],nil];

        int pi = 32;
        for (NSUInteger i = 0; i < 11; ++i) {
            float p = (pi-32) / 70.0;
            pi += [[scale objectAtIndex:(i % scale.count)] intValue];
            SK1 *sk = [[SK1 alloc] initWithAlpha:p AndPitch:pi AndSize:(p+.15)*14 AndStroke:4 AndBus:[sound busAt:i%2]];
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
    SK1 *a = (SK1*) contact.bodyA.node;
    BOOL anode = [a isKindOfClass:[SK1 class]];

    SK1 *b = (SK1*) contact.bodyB.node;
    BOOL bnode = [b isKindOfClass:[SK1 class]];
    
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

CGPoint touchLocation;
SKSpriteNode *touchedNode;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchLocation = [touch locationInNode:self];
    touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    BOOL anode = [touchedNode isKindOfClass:[SK1 class]];
    if (anode)
        touchedNode.physicsBody.velocity = CGVectorMake(0,0);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL anode = [touchedNode isKindOfClass:[SK1 class]];
    if (anode)
    {
        for (UITouch *touch in touches)
        {
            CGPoint location = [touch locationInNode:self];
            touchedNode.position = location;
            break;
        }
    }
    else
    {
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL anode = [touchedNode isKindOfClass:[SK1 class]];
    if (anode)
    {
        for (UITouch *touch in touches)
        {
            CGPoint location = [touch locationInNode:self];
            CGVector vec = CGVectorMake((location.x - touchLocation.x) * 11, (location.y - touchLocation.y) * 11);
            [touchedNode.physicsBody applyForce:vec];
            break;
        }
        [self setTimeScale:1];
    }
}




-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
