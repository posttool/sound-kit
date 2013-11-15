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


-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        sound = [[SKAudio alloc] init];
        
        joints = [[NSMutableArray alloc] init];
        
        SKScale * scale = [[SKScale alloc] initWithJSONFile:@"major"];
        
        for (NSUInteger i = 0; i < 21; ++i)
        {
            
            int pitch = [scale pitchAt:i];
            SKThingProp * prop = [scale propAt:i];
            SKThing *sk = [[SKThing alloc] initWithAlpha:1
                                                andPitch:pitch
                                                 andSize:prop.size
                                               andStroke:1
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

CGPoint touchLocation;
SKSpriteNode *touchedNode;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchLocation = [touch locationInNode:self];
    touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    BOOL anode = [touchedNode isKindOfClass:[SKThing class]];
    if (anode)
        touchedNode.physicsBody.velocity = CGVectorMake(0,0);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL anode = [touchedNode isKindOfClass:[SKThing class]];
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
    BOOL anode = [touchedNode isKindOfClass:[SKThing class]];
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
