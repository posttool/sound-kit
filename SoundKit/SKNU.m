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
@synthesize type = _type;
@synthesize subtype = _subtype;
@synthesize node = _node;
@synthesize nodeInitialized = _nodeInitialized;
@synthesize unit = _unit;
@synthesize unitInitialized = _unitInitialized;
@synthesize target = _target;
@synthesize targetInitialized = _targetInitialized;


-(id) init:(int)type :(int)subtype
{
    if (!self)
        return nil;
    _type = type;
    _subtype = subtype;
    _nodeInitialized = NO;
    _unitInitialized = NO;
    _targetInitialized = NO;
    return self;
}

- (void) node:(AUGraph)processingGraph
{
    if (_nodeInitialized)
        return;
    
    AudioComponentDescription cd = {};
    cd.componentType = _type;
    cd.componentSubType = _subtype;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags         = 0;
    cd.componentFlagsMask     = 0;
    
    OSStatus result = AUGraphAddNode(processingGraph, &cd, &_node);
    [SKAudioError check:result :"add node"];
    _nodeInitialized = YES;
    NSLog(@"added node");
}

- (void) unit:(AUGraph)processingGraph
{
    if (_unitInitialized)
        return;
    if (!_nodeInitialized)
        return;
    OSStatus result = AUGraphNodeInfo(processingGraph, self.node, NULL, &_unit);
    [SKAudioError check:result :"set node info"];
    _unitInitialized = YES;
    NSLog(@"added unit");
}


- (void) addTo:(AUGraph)processingGraph
{
    [self node:processingGraph];
    [self unit:processingGraph];
    
}


- (void) wire:(AUGraph)processingGraph :(AUNode)target
{
    [self wire:processingGraph :target :0];
}

- (void) wire:(AUGraph)processingGraph :(AUNode)target :(int)targetInput
{
    NSLog(@"NU wrire %hhd %hhd", _unitInitialized, _targetInitialized);
    if (!_unitInitialized)
        return;
    if (_targetInitialized)
        return;
    
    NSLog(@"wiring");
    OSStatus result = AUGraphConnectNodeInput(processingGraph, self.node, 0, target, targetInput);
    [SKAudioError check:result :"connect node input"];
//    _target = target;
    _targetInitialized = YES;
    NSLog(@"wired to target");
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
