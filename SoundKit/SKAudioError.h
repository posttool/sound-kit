//
//  SKAudioError.h
//  SoundKit
//
//  Created by david karam on 11/13/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKAudioError : NSObject
+(void) check:(OSStatus) error;
+(void) check:(OSStatus) error :(const char *)operation;
@end
