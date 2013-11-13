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
@synthesize samplerNode = _samplerNode;
@synthesize samplerUnit = _samplerUnit;
@synthesize bankURL = _bankURL;

- (id) init:(NSURL *)bankURL
{
    if ( self = [super init] )
    {
        _bankURL = bankURL;
    }
    
    return self;
}

- (void) wire:(AUGraph)processingGraph :(AUNode)mixer :(int)samplerOutputElement :(int)mixerInputElement
{
    OSStatus result = noErr;
    
    // create the sampler
    AudioComponentDescription cd = {};
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_Sampler;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    result = AUGraphAddNode(processingGraph, &cd, &_samplerNode);
    [SKAudioError check:result :"add sampler node"];

    AUGraphNodeInfo(processingGraph, self.samplerNode, NULL, &_samplerUnit);
    [SKAudioError check:result :"add sampler node info (unit)"];

    result = AUGraphConnectNodeInput(processingGraph,
                            self.samplerNode, samplerOutputElement, // srcnode, inSourceOutputNumber
                            mixer, mixerInputElement); // destnode, inDestInputNumber
    [SKAudioError check:result :"connect sampler to mixer"];
    
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) _bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) 0;
    
    // set the kAUSamplerProperty_LoadPresetFromBank property
    result = AudioUnitSetProperty(self.samplerUnit,
                                  kAUSamplerProperty_LoadPresetFromBank,
                                  kAudioUnitScope_Global,
                                  0,
                                  &bpdata,
                                  sizeof(bpdata));
    [SKAudioError check:result :"load preset"];
 
}



- (void)noteOn:(UInt32)noteNum :(UInt32)velocity
{
    UInt32 noteCommand = 0x90 | 0;
NSLog(@"playNoteOn %lu %lu cmd %lx", noteNum, velocity, noteCommand);
    OSStatus result = MusicDeviceMIDIEvent(_samplerUnit, noteCommand, noteNum, velocity, 0);
    [SKAudioError check:result :"noteOn"];
}

- (void)noteOff:(UInt32)noteNum
{
    UInt32 noteCommand = 0x80 | 0;
    OSStatus result = MusicDeviceMIDIEvent(_samplerUnit, noteCommand, noteNum, 0, 0);
    [SKAudioError check:result :"noteOff"];
}
@end
