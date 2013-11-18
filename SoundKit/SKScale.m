//
//  SKScale.m
//  SoundKit
//
//  Created by david karam on 11/15/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SKScale.h"

@implementation SKScale

@synthesize scale = _scale;

- (id) initWithJSONFile:(NSString*)filename
{
    return [self initWithArray:[SKScale readScale:filename]];
}

- (id) initWithArray:(NSArray*)scale
{
    self = [super self];
    if (self)
    {
        _scale = [[NSMutableArray alloc] init];
        for (NSDictionary * d in scale)
        {
            [_scale addObject:[[SKThingProp alloc] initWithDict:d]];
        }
        _allPitches = [[NSMutableArray alloc] init];
        for (int i = 0; i < 12; i++)
        {
            for (int j = 0; j < [_scale count]; j++)
            {
                SKThingProp * p = [self propAt: j];
                int pitch = i * 12 + p.pitch;
                [_allPitches addObject:[NSNumber numberWithInt:pitch]];
            }
        }
    }
    return self;
}

- (int) pitchAt:(int)index
{
    return [[_allPitches objectAtIndex:index] intValue];
}

- (SKThingProp *) propAt:(int)index
{
    return [_scale objectAtIndex:index % _scale.count];
}

// utility
+(NSArray *)readScale:(NSString*)name
{
    NSUInteger po = 0; //NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves;
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSInputStream *is = [[NSInputStream alloc] initWithFileAtPath:path];
    [is open];
    NSError *err = noErr;
    NSArray *scale = [NSJSONSerialization JSONObjectWithStream:is options:po error:&err];
    if (err)
        NSLog(@"err=%@", err);
    [is close];
    return scale;
}
@end
