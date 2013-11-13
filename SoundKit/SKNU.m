//
//  SKNU.m
//  SoundKit
//
//  Created by david karam on 11/13/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SKNU.h"
#import "SKAudioError.h"
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@implementation SKNU
@synthesize node = _node;
@synthesize unit = _unit;
int _type;
int _subtype;
AudioComponentDescription cd = {};

-(id) init:(int)type :(int)subtype
{
    if (!self)
        return nil;
    _type = type;
    _subtype = subtype;
    return self;
}

- (void) wire:(AUGraph)processingGraph :(AUNode)target
{
    [self wire:processingGraph :target :0];
}

- (void) wire:(AUGraph)processingGraph :(AUNode)target :(int)targetInput
{

    AudioComponentDescription cd = {};
    cd.componentType = _type;
    cd.componentSubType = _subtype;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    OSStatus result = AUGraphAddNode(processingGraph, &cd, &_node);
    [SKAudioError check:result :"add sampler node"];

    AUGraphNodeInfo(processingGraph, self.node, NULL, &_unit);
    [SKAudioError check:result :"add sampler unit"];

    result = AUGraphConnectNodeInput(processingGraph,
                                     self.node, 0,
                                     target, targetInput);
    [SKAudioError check:result :"connect sampler to mixer"];

    
}

-(void)loadSF:(NSURL*)bankURL
{
    // load soundfont
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) 0;
    
    // set the kAUSamplerProperty_LoadPresetFromBank property
    OSStatus result = AudioUnitSetProperty(_unit,
                                  kAUSamplerProperty_LoadPresetFromBank,
                                  kAudioUnitScope_Global,
                                  0,
                                  &bpdata,
                                  sizeof(bpdata));
    [SKAudioError check:result :"load preset"];

}
@end
