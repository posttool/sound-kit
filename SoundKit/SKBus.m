//
//  SKNu.m
//  SoundKit
//
//  Created by david karam on 11/13/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//


#import "SKBus.h"
#import "SKAudioError.h"

@implementation SKBus
@synthesize sampler = _sampler;
@synthesize effect = _effect;
@synthesize bankURL = _bankURL;

- (id) init:(NSURL *)b
{
    if ( self = [super init] )
    {
        _bankURL = b;
    }
    
    return self;
}



- (id) init:(NSString*)path :(NSString*)type
{
    if ( self = [super init] )
    {
        NSString*s = [[NSBundle mainBundle] pathForResource:path ofType:type];
        _bankURL = [[NSURL alloc] initFileURLWithPath:s];;
    }
    
    return self;
}

- (void) wire:(AUGraph)processingGraph :(AUNode)mixer :(int)mixerInput
{
    _effect = [[SKNU alloc] init:kAudioUnitType_Effect :kAudioUnitSubType_Delay];
    [_effect addTo:processingGraph];
    [_effect wire:processingGraph :mixer :mixerInput];
    
    _sampler = [[SKNU alloc] init:kAudioUnitType_MusicDevice :kAudioUnitSubType_Sampler];
    [_sampler addTo:processingGraph];
    [_sampler wire:processingGraph :_effect.node];
    [_sampler loadSF:_bankURL];
    
}





- (void)noteOn:(UInt32)noteNum :(UInt32)velocity
{
    UInt32 noteCommand = 0x90 | 0;
//NSLog(@"playNoteOn %lu %lu cmd %lx", noteNum, velocity, noteCommand);
    OSStatus result = MusicDeviceMIDIEvent(_sampler.unit, noteCommand, noteNum, velocity, 0);
    [SKAudioError check:result :"noteOn"];
}

- (void)noteOff:(UInt32)noteNum
{
    UInt32 noteCommand = 0x80 | 0;
    OSStatus result = MusicDeviceMIDIEvent(_sampler.unit, noteCommand, noteNum, 0, 0);
    [SKAudioError check:result :"noteOff"];
}
@end
