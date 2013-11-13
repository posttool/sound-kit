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
        
        
        sound = [[SKAudio alloc] init];
        
        joints = [[NSMutableArray alloc] init];

        
        
        
        
        
        
        scale = [NSMutableArray arrayWithObjects:
                 [NSNumber numberWithInt:5],
                 [NSNumber numberWithInt:4],
                 [NSNumber numberWithInt:3],nil];
        
//        scale = [NSMutableArray arrayWithObjects:
//                 [NSNumber numberWithInt:4],
//                 [NSNumber numberWithInt:3],
//                 [NSNumber numberWithInt:5],nil];

        
        CGSize cellSize = CGSizeMake(60, 60);
        CGSize gridSpace = CGSizeMake(33, 33);
        NSUInteger rowCount = 3;
        NSUInteger colCount = 3;
        
        int pi = 44;
        CGPoint baseOrigin = CGPointMake(50, 150);
        for (NSUInteger row = 0; row < rowCount; ++row) {
                CGPoint pos = CGPointMake(baseOrigin.x, row * (gridSpace.height + cellSize.height) + baseOrigin.y);
                for (NSUInteger col = 0; col < colCount; ++col) {
                    int f = row * colCount + col;
                    float p = (float)f / (float)(rowCount*colCount);
                    SK1 *sk = [[SK1 alloc] initWithAlpha:p AndPitch:pi AndSize:40 AndStroke:4 AndBus:sound.bus];
                    sk.position = pos;
                    [self addChild:sk];
                    pos.x += cellSize.width + gridSpace.width;
                    pi += [[scale objectAtIndex:(f % scale.count)] intValue];
                }
        }
        scale = [NSMutableArray arrayWithObjects:
                 [NSNumber numberWithInt:2],
                 [NSNumber numberWithInt:2],
                 [NSNumber numberWithInt:3],
                 [NSNumber numberWithInt:2],
                 [NSNumber numberWithInt:3],nil];
        
        //pi = 44+36;
        pi += 12;
        baseOrigin = CGPointMake(180, 50);
        for (NSUInteger row = 0; row < rowCount; ++row) {
            CGPoint pos = CGPointMake(baseOrigin.x, row * (gridSpace.height + cellSize.height) + baseOrigin.y);
            for (NSUInteger col = 0; col < colCount; ++col) {
                int f = row * colCount + col;
                float p = (float)f / (float)(rowCount*colCount);
                SK1 *sk = [[SK1 alloc] initWithAlpha:p AndPitch:pi AndSize:15 AndStroke:4 AndBus:sound.bus];
                sk.position = pos;
                [self addChild:sk];
                pos.x += cellSize.width + gridSpace.width;
                pi += [[scale objectAtIndex:(f % scale.count)] intValue];
            }
        }
        
        
        //
        anchorPoint = CGPointMake (0.5,0.5);
        world = [SKNode node];
        [self addChild:world];
        camera = [SKNode node];
        camera.name = @"camera";
        [world addChild:camera];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        
        self.physicsWorld.speed = 1.1;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
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
//    SKShapeNode *a = (SKShapeNode*) contact.bodyA.node;
//    NSNumber *alpha = a.userData[@"alpha"];
//    if ([a isKindOfClass:[SKShapeNode class]])
//    {
//        a.fillColor = [self color1:alpha.floatValue];
//        a.glowWidth = 1;
//    }
//    SKShapeNode *b = (SKShapeNode*) contact.bodyB.node;
//    alpha = b.userData[@"alpha"];
//    if ([b isKindOfClass:[SKShapeNode class]])
//    {
//        b.fillColor = [self color1:alpha.floatValue];
//        b.glowWidth = 1;
//    }
//    
//    NSNumber *pitch = a.userData[@"pitch"];
//    [sound playNoteOff:pitch.intValue];
//    pitch = b.userData[@"pitch"];
//    [sound playNoteOff:pitch.intValue];
}

//


// touching


CGPoint touchLocation;
SKSpriteNode *touchedNode;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    touchLocation = [touch locationInNode:self];
    touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    touchedNode.physicsBody.velocity = CGVectorMake(0,0);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
//        CGVector vec = CGVectorMake((location.x - touchLocation.x) * 3, (location.y - touchLocation.y) * 3);
//        [touchedNode.physicsBody applyForce:vec];
//        touchLocation = location;
        touchedNode.position = location;
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGVector vec = CGVectorMake((location.x - touchLocation.x) * 33, (location.y - touchLocation.y) * 33);
        [touchedNode.physicsBody applyForce:vec];
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}




-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
