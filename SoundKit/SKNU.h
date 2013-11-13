//
//  SKNU.h
//  SoundKit
//
//  Created by david karam on 11/13/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SKNU : NSObject 
@property (readonly) AUNode node;
@property (readonly) AudioUnit unit;

- (id)   init:(int)type :(int)subtype;
- (void) loadSF:(NSURL*)bankURL;
- (void) wire:(AUGraph)processingGraph :(AUNode)target ;
- (void) wire:(AUGraph)processingGraph :(AUNode)target :(int)targetInput;
@end
