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
@property (readonly) int type;
@property (readonly) int subtype;
@property (readonly) AUNode node;
@property (readonly) BOOL nodeInitialized;
@property (readonly) AudioUnit unit;
@property (readonly) BOOL unitInitialized;
@property (readonly) AUNode target;
@property (readonly) BOOL targetInitialized;

- (id)   init:(int)type :(int)subtype;
- (void) loadSF:(NSURL*)bankURL;
- (void) node:(AUGraph)processingGraph ;
- (void) unit:(AUGraph)processingGraph ;
- (void) addTo:(AUGraph)processingGraph ;
- (void) wire:(AUGraph)processingGraph :(AUNode)target ;
- (void) wire:(AUGraph)processingGraph :(AUNode)target :(int)targetInput;
@end
