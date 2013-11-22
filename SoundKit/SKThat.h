//
//  SK1.h
//  SoundKit
//
//  Created by david karam on 11/7/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKThat : SKShapeNode
@property (readonly) SKColor * color;
@property (readonly) CGSize size;

- (id) initWithSize:(CGSize)size;
- (void) destroy;

@end
