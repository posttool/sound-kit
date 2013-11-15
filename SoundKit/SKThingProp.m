//
//  SKThingProp.m
//  SoundKit
//
//  Created by david karam on 11/15/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SKThingProp.h"

@implementation SKThingProp

@synthesize pitch = _pitch;
@synthesize color = _color;
@synthesize size = _size;
@synthesize name = _name;

- (id) initWithDict:(NSDictionary *) dict
{
    self = [super self];
    if (self)
    {
        _pitch = [dict[@"pitch"] intValue];
        _color = [[SKColor alloc] initWithRed:[dict[@"color"][0] floatValue]
                                        green:[dict[@"color"][1] floatValue]
                                         blue:[dict[@"color"][2] floatValue]
                                        alpha:[dict[@"color"][3] floatValue]];
        _size = [dict[@"size"] floatValue];
        _name = dict[@"name"];
    }
    return self;
}

@end
