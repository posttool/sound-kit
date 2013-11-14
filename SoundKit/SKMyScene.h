//
//  SKMyScene.h
//  SoundKit
//

//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CMMotionManager.h>

@interface SKMyScene : SKScene<SKPhysicsContactDelegate, UIAccelerometerDelegate>
@property (strong) CMMotionManager* motionManager;
-(void)setTimeScale:(float)scale;
@end
